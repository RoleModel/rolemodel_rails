# frozen_string_literal: true

class EventRegistrationInfo < ApplicationRecord
  MAX_BANNER_SIZE = 10_000_000 # 10mb
  UNAA_LEAGUE_MEMBER_DISCOUNT = 10

  belongs_to :event
  has_many :price_variations, -> { order(position: :asc) }, dependent: :destroy
  has_many :promotional_codes, dependent: :nullify
  has_one_attached :photo
  alias_attribute :limits, :registration_limits

  validates :event, :price, :price_name, presence: true
  # Rails 6 will implement better ActiveStorage validations
  # Should look into that when we upgrade
  validate :photo_validation

  def price_of(registration_item)
    matching_variation = price_variations.detect { |variation| variation.match(registration_item) }
    matching_variation.try(:price) || price
  end

  def address
    self[:address] || event.organization.address
  end

  def limit!(tag, quantity)
    limits[tag] = quantity
    save!
  end

  # TODO: at some point, count contestants for a tag
  def limit_reached?(*tags)
    # the following is a hack for UBW Labor Day
    slots = %w[Wave-1-Friday Wave-2 Wave-3]
    ubw_divisions = %w[7-under 9-under 11-under 13-under 17-under 18+ 40+]
    slot = tags.detect { |tag| slots.include?(tag) }
    division = tags.detect { |tag| ubw_divisions.include?(tag) }
    if slot && division
      count = event.event_contestants.count do |contestant|
        contestant_tags = contestant.tags.split
        contestant_tags.include?(slot) && contestant_tags.include?(division)
      end
      return true if count >= 60
    end

    tags.any? { |tag| limits[tag] }
  end

  def default_description
    <<~HEREDOC
      <h1>Ninja Warrior Competition</h1>
      <div>Come experience the sport that American Ninja Warrior inspired.</div>
      <div></div>
      <div><em>More details to come</em></div>
      <div></div>
      <div>Our competition will follow Ultimate Ninja Athlete Association (UNAA) rules and age/classes based on your age as of August 1, 2018.</div>
      <div>This competition will include both children and adults in their respective categories on age appropriate courses</div>
      <div></div>
      <h1>Prices (before convenience fees)</h1>
      <div>Sign up now to reserve your spot. All participants must sign our waiver.</div>
      <ul>
        <li>Participant $30</li>
      </ul>
      <div></div>
      <h1>Tentative Schedule</h1>
      <div>All times are subject to change.</div>
      <div></div>
      <div><em>Specific start times for each age group still to be determined</em></div>
    HEREDOC
  end

  def includes_promo_code?(promo_code)
    promotional_codes.include? promo_code
  end

  private

  # NOTE: As of Rails 6, if this model doesn't pass validation, the image will
  # not get persisted, but it WILL still show as attached! This means that if
  # we need to render with errors, we may need to check `photo.persisted?` in
  # addition to `photo.attached?` before doing things like variation in size.
  def photo_validation
    return unless photo.attached?

    if photo.blob.byte_size > MAX_BANNER_SIZE
      errors[:banner] << 'must be smaller than 10mb'
    elsif %w[image/png image/gif image/jpeg].exclude?(photo.blob.content_type)
      errors[:banner] << 'must be an image file'
    end
  end
end
