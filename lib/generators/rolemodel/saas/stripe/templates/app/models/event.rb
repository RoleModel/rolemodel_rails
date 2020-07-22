# frozen_string_literal: true

class Event < ApplicationRecord
  MAX_BANNER_SIZE = 1_000_000 # 1mb

  belongs_to :organization
  belongs_to :sanction, optional: true
  has_one :season, through: :sanction
  has_one :league, through: :season
  has_many :courses, dependent: :restrict_with_error
  has_many :event_contestants, dependent: :destroy, inverse_of: :event
  alias_attribute :contestants, :event_contestants
  has_many :registration_orders
  has_many :registration_items, lambda {
    merge(RegistrationOrder.paid)
      .where(refunded_amount: 0)
  }, through: :registration_orders
  has_many :tickets
  has_one :event_registration_info # until we have soft deletes... holding off on, dependent: :destroy
  alias_attribute :registration_info, :event_registration_info
  has_many :waves, dependent: :destroy

  scope :current_and_past, -> { where('start_date <= ?', Date.current) }
  scope :current_and_future, -> { where('end_date >= ?', Date.current) }
  scope :last_7_days, -> { current_and_past.where('end_date >= ?', 7.days.ago) }
  scope :by_newest_start_date, -> { order(start_date: :desc) }
  scope :by_oldest_start_date, -> { order(start_date: :asc) }
  scope :virtual, -> { where(virtual: true) }
  scope :uses_registration, -> { virtual.or(where(enable_registration: true)) }
  scope :with_league_courses, ->(rule_set) { joins(:courses).where(courses: { rule_set: rule_set }).distinct.includes(:courses) }
  scope :with_awg_courses, -> { with_league_courses('RuleSet::AWG') }
  scope :with_courses, -> { joins(:courses).distinct }

  validate :virtual_event_is_in_future, on: :create
  validates :name, :start_date, :end_date, presence: true
  validate :ends_after_start_date
  validate :used_tags_included
  validate :official_tags_included

  serialize :tag_config, TagConfig

  accepts_nested_attributes_for :organization, update_only: true

  before_save :set_end_date_time

  def self.for_season(season)
    self.current_and_past.where("start_date >= ?", season.start_date).where("end_date <= ?", season.end_date)
  end

  def regions
    season&.regions.to_a
  end

  def registration_closed?
    Date.current >= [end_date, registration_closed_at].compact.min
  end

  def approx_date
    start_date.to_date.strftime('%b %Y')
  end

  def dates
    return start_date if start_date == end_date.to_date

    "#{start_date} \u2014 #{end_date.to_date}" # &mdash;
  end

  def normalized_dates
    formatted_start = start_date.strftime('%a %B %d, %Y')
    return formatted_start if start_date == end_date.to_date

    formatted_end = end_date.to_date.strftime('%a %B %d, %Y')

    "#{formatted_start} \u2014 #{formatted_end}" # &mdash;
  end

  def duplicate_event(attrs, new_name, include_details)
    new_event = include_details ? dup : Event.new(name: name, organization_id: organization_id)
    new_event.update(attrs.merge(name: "#{new_name} (copy)", virtual: false))
    new_event
  end

  def duplicate_courses(duplicate_event_id, include_courses)
    if include_courses
      courses.by_id.each do |course|
        duplicate_course = duplicate_course(course, duplicate_event_id)
        duplicate_course.duplicate_obstacles_from(course.id)
      end
    else
      Course.create(event_id: duplicate_event_id, name: 'Stage 1')
    end
  end

  def duplicate_contestants(duplicate_event_id, include_contestants)
    return unless include_contestants

    event_contestants.each do |contestant|
      duplicate_contestant = contestant.dup
      duplicate_contestant.update(event_id: duplicate_event_id)
    end
  end

  def register_athlete(athlete, tags)
    return false unless required_tags_set?(tags)

    EventContestant.find_or_initialize_by(event: self, athlete: athlete) do |contestant|
      contestant.contestant_course_runs.build(
        wave: virtual_wave,
        course: virtual_wave.course
      )
    end.update!(name: athlete.name, tags: tags)
  end

  def as_json(options = {})
    super(options.reverse_merge(only: %i[id name start_date end_date sanction_id])).merge(
      courses: courses,
      requires_league_membership: requires_league_membership?
    )
  end

  def default_division_for_athlete(athlete)
    age = athlete.age_on(start_date)
    division_tags = Array(tag_config[:classes])
    tag = age_based_tag(age, division_tags) if age
    tag ||= default_tag(division_tags)
    tag || ('amateur' if division_tags.include?('amateur'))
  end

  def default_tag(division_tags)
    age_undetermined_tags(division_tags).last
  end

  def age_undetermined_tags(division_tags)
    division_tags.reject { |tag| /\d+/ =~ tag }
  end

  def age_based_tag(age,division_tags)
    or_under_tags = division_tags.select{|tag| /\d+-/ =~ tag}
    #assumes they are in ascending order
    or_under_tags.each do |tag|
      return tag if age <= /(\d+)/.match(tag)[1].to_i
    end
    or_over_tags = division_tags.select{|tag| /\d+\+/ =~ tag}
    or_over_tags.each do |tag|
      return tag if age >= /(\d+)\+/.match(tag)[1].to_i
    end
    return nil
  end

  def to_param
    [id, name.parameterize].join('-')
  end

  # Ensure that each Tag Config Type has at least one Tag set
  def required_tags_set?(tags)
    tags = tags.to_s.split
    tag_config.all? { |key, tags_from_config| key == 'other' || (tags_from_config & tags).any? }
  end

  def virtual_wave
    if waves.empty?
      waves.create!(name: 'Virtual Wave', course: courses.first)
    else
      waves.first
    end
  end

  def tags_in_use
    refunded_item_ids = Refund.where(registration_order_id: registration_orders.ids).pluck(:registration_items).flatten.map(&:id)
    items = RegistrationItem.where(registration_order_id: registration_orders.ids, refunded_amount: 0).where.not(id: refunded_item_ids)
    registration_item_tags = items.pluck(:tags).compact.flat_map(&:split).uniq
    price_variation_tags = event_registration_info&.price_variations&.pluck(:tags)&.flatten&.uniq
    (used_tags.to_a + registration_item_tags.to_a + price_variation_tags.to_a).uniq.sort
  end

  def used_tags
    event_contestants.pluck(:tags).compact.flat_map(&:split).uniq.sort
  end

  def contestant_count
    event_contestants.size
  end

  def gender_counts
    contestants_tag_list = EventContestant.where(event_id: id).pluck(:tags).compact.map(&:split).flatten

    tag_config.fetch(:gender, []).each_with_object({}) do |gender, hash|
      hash[gender.to_sym] = contestants_tag_list.count(gender)
    end
  end

  def gender_counts_string
    gender_counts.map{|gender, count| "#{gender}: #{count}"}.join(', ')
  end

  def classes_tag_summary
    contestants_tag_list = EventContestant.where(event_id: id).pluck(:tags).compact.map(&:split)

    return {} if contestants_tag_list.empty?
    tag_config.fetch(:classes, []).each_with_object({}) do |class_tag, hash|
      hash[class_tag.to_sym] = {
        class: class_overall_counts(contestants_tag_list, class_tag),
        gender: class_gender_counts(contestants_tag_list, class_tag)
      }
    end
  end

  def is_full?
    organization.max_contestants && (event_contestants.count >= organization.max_contestants)
  end

  def requires_league_membership?
    league&.events_require_membership?
  end

  private

  def class_overall_counts(contestants_tag_list, class_tag)
    overall_counts = {}
    overall_counts[:total] = contestants_tag_list.count { |tags| tags.include?(class_tag) }
    event_contestants_other_time_slot_tags.each do |contestant_tag|
      overall_counts[contestant_tag.to_sym] = contestants_tag_list.count do |tags|
        tags.include?(class_tag) && tags.include?(contestant_tag)
      end
    end
    overall_counts
  end

  def class_gender_counts(contestants_tag_list, class_tag)
      gender_hash = {}
      tag_config.fetch(:gender, []).each do |gender|
        gender_others_counts = {}
        gender_others_counts[:total] = contestants_tag_list.count do |tags|
          tags.include?(class_tag) && tags.include?(gender)
        end
        event_contestants_other_time_slot_tags.each do |contestant_tag|
          gender_others_counts[contestant_tag.to_sym] = contestants_tag_list.count do |tags|
            tags.include?(class_tag) && tags.include?(gender) && tags.include?(contestant_tag)
          end
        end
        gender_hash[gender.to_sym] = gender_others_counts
      end
      gender_hash
  end

  def event_contestants_other_time_slot_tags
    tags = used_tags.reject{ |tag| tag_config.fetch(:gender, []).include?(tag)}
    tags.reject{ |tag| tag_config.fetch(:classes, []).include?(tag)}
  end

  def used_tags_included
    all_tags = tag_config.values.flatten
    missing_tags = tags_in_use.reject { |tag| all_tags.include?(tag) }
    return if missing_tags.none?

    plural = missing_tags.one? ? 'is' : 'are'
    errors.add(:tag_config, "#{missing_tags.to_sentence} #{plural} currently in use and must be included. Please contact support if you need help")
  end

  def official_tags_included
    return unless sanction_id

    set_tags = tag_config.values.flatten
    season_tags = season.tag_config.values.flatten
    missing_tags = season_tags - set_tags

    return if missing_tags.empty?

    errors.add(:tag_config, "All official tags must be used. Please add #{missing_tags.to_sentence}")
  end

  def set_end_date_time
    self.end_date = end_date.end_of_day
  end

  def duplicate_course(course, duplicate_event_id)
    duplicate_course = course.dup
    duplicate_course.update(event_id: duplicate_event_id, finished: false)
    duplicate_course
  end

  def virtual_event_is_in_future
    if virtual && start_date < Date.current
      errors.add(:virtual, 'needs to be in the future')
    end
  end

  def ends_after_start_date
    return if end_date >= start_date

    errors.add(:end_date, 'must be after start date')
  end

  def photo_validation
    return unless photo.attached?

    if photo.blob.byte_size > MAX_BANNER_SIZE
      photo.purge
      errors[:banner] << 'must be smaller than 1mb'
    elsif %w[image/png image/gif image/jpeg].exclude?(photo.blob.content_type)
      photo.purge
      errors[:banner] << 'must be an image file'
    end
  end
end
