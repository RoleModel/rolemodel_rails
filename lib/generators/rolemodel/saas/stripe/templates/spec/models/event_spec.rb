require 'rails_helper'

RSpec.describe Event, type: :model do
  describe '.new' do
    let(:event) { build :event }

    it 'is valid' do
      expect(event).to be_valid
    end
  end

  describe 'validations' do
    context 'start date rule' do
      let(:today) { Date.current }

      it 'does not allow past start date events to be virtual ' do
        past_date_event = build(:event, start_date: today - 1.day, virtual: true)
        expect(past_date_event).not_to be_valid
      end

      it 'allows future start date events to be virtual' do
        future_date_event = build(:event, start_date: today + 1.day, virtual: true)
        expect(future_date_event).to be_valid
      end
    end

    context 'end date rule' do
      let(:today) { Date.current }

      it 'does not allow dates before start_date' do
        event = build(:event, start_date: Date.current, end_date: Date.yesterday)
        expect(event).not_to be_valid
      end

      it 'allows start and end dates to match' do
        event = build(:event, start_date: Date.current, end_date: Date.current)
        expect(event).to be_valid
      end

      it 'allows end date to be later than start_date' do
        event = build(:event, start_date: Date.current, end_date: Date.tomorrow)
        expect(event).to be_valid
      end
    end

    context 'tag config' do
      it 'cannot remove tags that are in use' do
        event = create(:event, tag_config: { classes: %w[6-7 8-10 11-14 15-20 21-25], gender: %w[male female] })
        create(:event_contestant, event: event, tags: '15-20 male')

        event.tag_config = { classes: %w[6-7 8-10], gender: %w[male female] }

        expect(event).not_to be_valid
        expect(event.errors[:tag_config]).to include "15-20 is currently in use and must be included. Please contact support if you need help"
      end

      it 'must include the all official tags from the season if a sanction is set' do
        tag_config = { classes: %w[9-under 11-under 13-under 15-under], gender: %w[male female] }
        season = create(:season, tag_config: tag_config)
        sanction = create(:sanction, season: season)
        event = build(:event, tag_config: tag_config, sanction: sanction)

        event.tag_config = { classes: %w[9-under 11-under custom], gender: %w[male] }

        expect(event).not_to be_valid
        expect(event.errors[:tag_config]).to include 'All official tags must be used. Please add female, 13-under, and 15-under'
      end
    end
  end

  describe 'end_date' do
    it 'sets the time to the end of the day' do
      end_of_day_time = '23:59:59'
      event = create :event, end_date: Date.current

      expect(event.end_date.to_s).to match(end_of_day_time)
    end
  end

  describe 'tickets' do
    let(:event) { create :event }

    it 'has an empty collection of tickets by default' do
      expect(event.tickets).to be_empty
    end
  end

  describe '#regions' do
    context 'when governing_body does haves regions' do
      it 'returns those regions' do
        league = create(:league, :awg)
        season = create :season, :with_regions, league: league
        sanction = create :sanction, season: season
        event = build :event, start_date: season.start_date + 1.day, default_rule_set: league.rule_set, sanction: sanction

        expect(event.regions).to match_array season.regions
      end
    end

    context 'when governing_body does not have regions' do
      it 'returns an empty array' do
        event = build :event
        expect(event.regions).to eq []
      end
    end
  end

  describe '#registration_closed?' do
    describe 'by end_date' do
      # let! is necessary so that event gets instantiated before Timecop takes over!
      let!(:event) { create(:event, start_date: 3.days.ago, end_date: 3.days.from_now) }

      it 'returns true if date is between start and end of event' do
        (-3..3).each do |day|
          Timecop.freeze(day.days.from_now) do
            expect(event).not_to be_registration_closed
          end
        end
      end

      it 'returns true if date is before start (and end) of event' do
        Timecop.freeze(5.days.ago) do
          expect(event).not_to be_registration_closed
        end
      end

      it 'returns false if date is outside of start and end of event' do
        Timecop.freeze(4.days.from_now) do
          expect(event).to be_registration_closed
        end
      end
    end

    describe 'by registration_closed_at' do
      # let! is necessary so that event gets instantiated before Timecop takes over!
      let!(:event) do
        create(
          :event,
          start_date: 3.days.ago, end_date: 5.days.from_now,
          registration_closed_at: 3.days.from_now
        )
      end

      it 'returns true if date is between start and end of registration' do
        (-3..3).each do |day|
          Timecop.freeze(day.days.from_now) do
            expect(event).not_to be_registration_closed
          end
        end
      end

      it 'returns true if date is before start (and end) of registration' do
        Timecop.freeze(5.days.ago) do
          expect(event).not_to be_registration_closed
        end
      end

      it 'returns false if date is outside of start and end of registration' do
        Timecop.freeze(4.days.from_now) do
          expect(event).to be_registration_closed
        end
      end
    end
  end

  describe 'scopes' do
    let(:today) { Date.current }
    let!(:past_event) { create(:event, start_date: 2.days.ago, end_date: 2.days.ago) }
    let!(:current_event) { create(:event, start_date: today) }
    let!(:future_event) { create(:event, start_date: 2.days.from_now, end_date: 1.year.from_now, virtual: true) }

    context '.by_newest_start_date' do
      it 'sorts the events by start date' do
        expect(Event.by_newest_start_date).to contain_exactly(future_event, current_event, past_event)
      end
    end

    context '.by_oldest_start_date' do
      it 'sorts the events by start date' do
        expect(Event.by_oldest_start_date).to contain_exactly(past_event, current_event, future_event)
      end
    end

    context '.current_and_past' do
      it 'returns the past and current events' do
        expect(Event.current_and_past).to contain_exactly(past_event, current_event)
      end
    end

    context '.current_and_future' do
      it 'returns the current and future events' do
        expect(Event.current_and_future).to contain_exactly(current_event, future_event)
      end
    end

    context '.last_7_days' do
      let!(:way_past_event) { create(:event, start_date: 10.days.ago) }
      let!(:way_past_ongoing_event) { create(:event, start_date: 10.days.ago, end_date: 1.day.from_now) }

      it 'returns the events that happened in the last 7 days' do
        expect(Event.last_7_days).to contain_exactly(past_event, current_event, way_past_ongoing_event)
      end
    end

    context '.uses_registration' do
      before do
        # +update_attribute+ is needed due to validation on event dates for virtual
        past_event.update_attribute(:virtual, true)
      end

      it 'returns virtual events' do
        expect(Event.uses_registration).to contain_exactly(past_event, future_event)
      end

      it 'returns can register events' do
        registerable_event = create(:event, :with_registration, start_date: 2.days.ago, end_date: 2.days.ago)
        past_event.update(virtual: false)
        expect(Event.uses_registration).to contain_exactly(registerable_event, future_event)
      end

      it 'returns registerable and virtual events' do
        registerable_event = create(:event, :with_registration, start_date: 2.days.ago, end_date: 2.days.ago)
        expect(Event.uses_registration).to contain_exactly(past_event, future_event, registerable_event)
      end
    end

    context '.with_awg_courses' do
      let(:awg_event) { create(:event) }
      let(:non_awg_event) { create(:event) }
      let!(:awg_course) { create(:course, :awg_qualifying, event: awg_event) }
      let!(:non_awg_course) { create(:course, rule_set: 'RuleSet::NNL', event: non_awg_event) }

      it 'returns events that have awg courses' do
        expect(Event.with_awg_courses).to eq [awg_event]
      end
    end

    context '.with_courses' do
      let(:event_with_courses) { create(:scheduled_event, start_date: today - 1.day) }
      let(:event_without_courses) { create(:event, start_date: today - 1.day) }

      it 'returns only events with courses' do
        expect(Event.with_courses).to include(event_with_courses)
        expect(Event.with_courses).not_to include(event_without_courses)
      end
    end
  end

  describe 'duplicating events' do
    let(:event) { create(:event, default_rule_set: 'RuleSet::AWG') }
    let!(:course) { create :course, event: event, finished: true }
    let!(:course2) { create :course, event: event, rule_set: 'RuleSet::AWG' }
    let!(:obstacle) { create :obstacle, name: 'Obstacle 1', course: course }
    let!(:obstacle2) { create :obstacle, name: 'Obstacle 2', course: course2 }
    let!(:contestant) { create :event_contestant, event: event }
    let!(:contestant2) { create :event_contestant, event: event }
    let!(:course_run) { create :contestant_course_run, course: course, event_contestant: contestant }
    let!(:course_run2) { create :contestant_course_run, course: course, event_contestant: contestant2 }
    let!(:obstacle_option) { create :option, name: 'Option 1', obstacle: obstacle }
    let!(:obstacle2_option) { create :option, name: 'Option 2', obstacle: obstacle2 }

    it 'creates an event with the organization_id copied, and name + start_date set' do
      attributes = { start_date: '2019-01-01', end_date: '2019-01-10' }
      new_event_name = 'Event Copy'
      new_event = event.duplicate_event(attributes, new_event_name, false)
      expect(new_event.name).to eq("#{new_event_name} (copy)")
      expect(new_event.organization_id).to eq(event.organization_id)
      expect(new_event.start_date).to eq(Date.new(2019, 1, 1))
      expect(new_event.end_date).to eq(Date.new(2019, 1, 10).end_of_day)
    end

    context 'duplicating the event object with details NOT selected' do
      let(:default_event) { create(:event) }

      it 'sets the remaining details of the event to the defaults' do
        include_details = false
        new_event = event.duplicate_event(
          { start_date: '2000-01-01', end_date: '2000-01-01' },
          event.name,
          include_details
        )
        expect(new_event.default_rule_set).to eq('RuleSet::Custom')
      end
    end

    context 'duplicating the event object with details selected' do
      it 'sets the remaining details to match the copied event' do
        include_details = true
        new_event = event.duplicate_event({ start_date: '2000-01-01' }, event.name, include_details)
        expect(new_event.default_rule_set).to eq('RuleSet::AWG')
      end
    end

    context 'duplicating the event courses' do
      let(:duplicate_event) { create :event }

      it 'creates a new course with no obstacles if course is NOT selected' do
        include_courses = false
        event.duplicate_courses(duplicate_event.id, include_courses)
        duplicate_courses = duplicate_event.courses
        expect(duplicate_courses.count).to be 1
        expect(duplicate_courses.first.obstacles.count).to be 0
      end

      it 'creates a copy of the courses with the obstacles if course is selected' do
        include_courses = true
        event.duplicate_courses(duplicate_event.id, include_courses)
        duplicate_courses = duplicate_event.courses
        expect(duplicate_courses.first.finished).to eq(false)
        expect(duplicate_courses.second.rule_set).to eq(course2.rule_set)
        expect(duplicate_courses.first.obstacles.first.name).to eq(obstacle.name)
        expect(duplicate_courses.second.obstacles.first.name).to eq(obstacle2.name)
      end

      it 'duplicates the options associated with the obstacles' do
        include_courses = true
        event.duplicate_courses(duplicate_event.id, include_courses)
        duplicate_courses = duplicate_event.courses
        first_duplicate_course = duplicate_courses.first
        second_duplicate_course = duplicate_courses.second
        duplicate_option = first_duplicate_course.obstacles.first.options.first
        duplicate_option2 = second_duplicate_course.obstacles.first.options.first
        expect(duplicate_option.name).to eq(obstacle_option.name)
        expect(duplicate_option2.name).to eq(obstacle2_option.name)
      end
    end

    context 'duplicating the event contestants' do
      let(:duplicate_event) { create :event }

      it 'does not create any contestants if contestants is NOT selected' do
        create :course, event: duplicate_event
        event.duplicate_contestants(duplicate_event.id, false)
        duplicate_contestants = duplicate_event.event_contestants
        expect(duplicate_contestants).to eq([])
      end

      it 'duplicates the event\'s contestants if contestants is selected' do
        create :course, event: duplicate_event
        expect {
          event.duplicate_contestants(duplicate_event.id, true)
        }.to change { duplicate_event.event_contestants.count }.from(0).to(2)
      end
    end
  end

  describe '#register_athlete' do
    let!(:athlete) { create :athlete }
    let(:tag_config) { { classes: %w[pro amateur], gender: %w[male female] } }
    let!(:event) { create :event, tag_config: tag_config }
    let!(:course) { create :course, event: event }
    let!(:wave) { create :wave, course: course, event: event }
    let(:tags) { 'pro female' }

    context 'when all the correct tags are set' do
      before { event.register_athlete(athlete, tags) }
      let(:contestant) { athlete.event_contestants.first }

      it 'creates a contestant in the event associated to the athlete' do
        expect(contestant.event_id).to eq(event.id)
      end

      it 'gives the contestant the same name as the athlete' do
        expect(contestant.name).to eq(athlete.name)
      end

      it 'sets the tags on the contestant' do
        expect(contestant.tags).to eq(tags)
      end

      it 'assigns the contestants to the virtual wave' do
        expect(contestant.contestant_course_runs.first.wave_id).to eq(event.virtual_wave.id)
      end
    end

    context 'when some tags are missing' do
      it 'returns false' do
        expect(event.register_athlete(athlete, '')).to eq(false)
        expect(event.register_athlete(athlete, 'pro')).to eq(false)
      end
    end

    context 'when the athlete is already registered' do
      let!(:contestant) do
        create :event_contestant, event: event, athlete: athlete, tags: 'other tag'
      end

      it 'updates the current event contestant' do
        expect do
          event.register_athlete(athlete, tags)
        end.not_to change(athlete.event_contestants, :count)

        expect(contestant.reload.tags).to eq(tags)
      end

      it 'does not create another course run' do
        expect do
          event.register_athlete(athlete, tags)
        end.not_to change(contestant.contestant_course_runs, :count)
      end
    end
  end

  describe '#virtual_wave' do
    let!(:virtual_event) { create(:virtual_event) }
    let!(:course) { create(:course, event: virtual_event) }

    context 'when a virtual event does not have any waves' do
      it 'creates and returns a new wave' do
        expect(virtual_event.waves.count).to eq(0)
        expect(virtual_event.virtual_wave).to be_instance_of Wave
        expect(virtual_event.virtual_wave.name).to eq('Virtual Wave')
        expect(virtual_event.waves.count).to eq(1)
      end
    end

    context 'when a virtual event has a wave' do
      let!(:existing_wave) { create(:wave, event: virtual_event, course: course) }

      it 'does not create a new wave and returns the first wave' do
        expect do
          virtual_event.virtual_wave
        end.not_to change(virtual_event.waves, :count)
        expect(virtual_event.virtual_wave).to eq(existing_wave)
      end
    end
  end

  describe '#used_tags' do
    let(:event) { create :event }
    context 'there are tags set' do
      it 'returns a sorted array of the tags' do
        create(:event_contestant, event: event, tags: 'm')
        create(:event_contestant, event: event, tags: 'f')
        expect(event.used_tags).to eq(%w[f m])
      end
    end

    context 'there are no tags' do
      it 'returns an empty array' do
        create(:event_contestant, event: event)
        expect(event.used_tags).to eq([])
      end
    end

    context 'there are multiple tags on a contestant' do
      it 'returns the tags as separate items in the array' do
        create(:event_contestant, event: event, tags: 'm adult')
        expect(event.used_tags).to match_array(%w[adult m])
      end
    end

    context 'there is an empty string tag' do
      it 'does not return it as a tag' do
        create(:event_contestant, event: event, tags: ' ')
        expect(event.used_tags).to eq([])
      end
    end

    context 'there are identical tags' do
      it 'only returns one of them' do
        tag = 'm'
        create(:event_contestant, event: event, tags: tag)
        create(:event_contestant, event: event, tags: tag)
        expect(event.used_tags).to eq([tag])
      end
    end
  end

  describe '#gender_counts' do
    let(:tag_config) { { gender: %w[male female] } }
    let(:gender_counts) { { male: 2, female: 1 } }
    let(:event) { create :event, tag_config: tag_config }
    let(:event_with_no_tags) { create :event, tag_config: {} }
    let!(:event_contestant1) { create(:event_contestant, event: event, tags: 'male' ) }
    let!(:event_contestant2) { create(:event_contestant, event: event, tags: 'female' ) }
    let!(:event_contestant3) { create(:event_contestant, event: event, tags: 'male' ) }

    it 'returns the genders in the tag config and the total contestants tagged with that gender' do
      expect(event.gender_counts).to eq gender_counts
    end

    it 'returns empty hash when there are no contestants with a gender' do
      expect(event_with_no_tags.gender_counts).to be_empty
    end
  end

  describe '#classes_tag_summary' do
    let(:tag_config) do
      {
        classes: %w[kids adults],
        gender: %w[male female],
        other: %w[pro amateur]
      }
    end
    let(:tag_class_summary) do
      {
        kids: {
          class: { total: 2, pro: 1, amateur: 1 },
          gender: {
            male: { total: 1, pro: 1, amateur: 0 },
            female: { total: 1, pro: 0, amateur: 1 }
          }
        },
        adults: {
          class: { total: 1, pro: 1, amateur: 0 },
          gender: {
            male: { total: 1, pro: 1, amateur: 0 },
            female: { total: 0, pro: 0, amateur: 0 }
          }
        }
      }
    end
    let(:event) { create :event, tag_config: tag_config }
    let(:event_with_contestants_no_tags) { create :event, tag_config: tag_config }
    let!(:event_contestant1) { create(:event_contestant, event: event, tags: 'kids male pro' ) }
    let!(:event_contestant2) { create(:event_contestant, event: event, tags: 'kids female amateur' ) }
    let!(:event_contestant3) { create(:event_contestant, event: event, tags: 'adults male pro' ) }

    it 'returns the number of male/female contestants in each class tag' do
      expect(event.classes_tag_summary).to eq tag_class_summary
    end

    it 'returns empty hash when there are no contestants with tags' do
      expect(event_with_contestants_no_tags.classes_tag_summary).to be_empty
    end
  end

  describe '#is_full?' do
    let(:organization) { create(:subscribed_organization) }
    let(:event) { create :event, organization: organization }
    let(:number_of_contestants) { 2 }

    before(:each) do
      allow_any_instance_of(Subscription).to receive(:max_contestants).and_return(number_of_contestants)
    end

    it 'returns false if the current number of event contestants already saved is less than the maximum number of contestants' do
      expect(event.is_full?).to be false
    end

    it 'returns true if the current number of event contestants already saved is equal to the maximum number of contestants' do
      number_of_contestants.times { create(:event_contestant, event: event) }
      expect(event.is_full?).to be true
    end

    it 'returns true if the current number of event contestants already saved is greater than the maximum number of contestants' do
      (number_of_contestants + 1).times { build(:event_contestant, event: event).save(validate: false) } # bypass event_contestant validation to bypass the max_contestants restraint
      expect(event.event_contestants.count).to eq 3
      expect(event.is_full?).to be true
    end
  end

  describe '#tags_in_use' do
    it 'includes all the tags used by contestants, registration (non-refunded), and price varients' do
      tags_in_use = %w[6-7 8-10 11-14 15-20 male female]
      event = create(:event, tag_config: { classes: %w[6-7 8-10 11-14 15-20 21-25], gender: %w[male female] })
      event_contestant = create(:event_contestant, event: event, tags: '15-20 male')
      registration_info = create(:event_registration_info, event: event)
      price_variation = create(:price_variation, event_registration_info: registration_info, tags: ['6-7', '8-10'])
      registration_order = create(:registration_order, event: event)
      create(:contestant_item, registration_order: registration_order, tags: '11-14 female')
      create(:contestant_item, registration_order: registration_order, tags: '21-25 female', refunded_amount: 20)
      refunded_item = create(:contestant_item, registration_order: registration_order, tags: '21-25 female', refunded_amount: 0)
      Refund.create(registration_order: registration_order, registration_items: [refunded_item], refunded_by: build(:user))

      expect(event.tags_in_use).to match_array tags_in_use
    end


    it 'returns an empty array when none of the tags are used' do
      event = create(:event, tag_config: { classes: %w[6-7 8-10 11-14 15-20 21-25], gender: %w[male female] })

      expect(event.tags_in_use).to eq []
    end
  end

  describe '#default_division_for_athlete' do
    let(:athlete) { build(:athlete) }
    let(:event) { build(:event) }

    it "gives a default for athletes without a birthdate if there are classes" do
      expect(event.default_division_for_athlete(athlete)).to eq event.tag_config[:classes].last
    end

    it "gives nil if there are no classes" do
      event.tag_config = {}
      expect(event.default_division_for_athlete(athlete)).to be_nil
    end

    it "gives last non-age-based tags if no age-based-match" do
      event.tag_config = { classes: %w[9-under 11-under 13-under 15-under amateur pro 40+], gender: %w[male female] }
      expect(event.default_division_for_athlete(athlete)).to eq 'pro'
    end

    it "finds an age tag if there is a birthdate compared to event start_date" do
      athlete.birthdate = event.start_date - 10.years - 1.day
      event.tag_config = { classes: %w[6-under 10-under 13-under 15-under amateur pro 36+], gender: %w[male female] }
      expect(event.default_division_for_athlete(athlete)).to eq '10-under'
      athlete.birthdate = event.start_date - 3.years
      expect(event.default_division_for_athlete(athlete)).to eq '6-under'
      athlete.birthdate = event.start_date - 36.years - 1.day
      expect(event.default_division_for_athlete(athlete)).to eq '36+'
    end
  end

  describe '#requires_league_membership?' do
    context 'when the event is associated with a league' do
      it 'returns true' do
        league = create(:league, :unaa, events_require_membership: true)
        season = create(:season, league: league)
        sanction = create(:sanction, season: season)
        event = create(:event, sanction: sanction, tag_config: season.tag_config)

        expect(event.requires_league_membership?).to eq true
      end
    end

    context 'when the event is not associated with a league' do
      it 'returns nil' do
        event = create :event
        create :course, event: event

        expect(event.requires_league_membership?).to eq nil
      end
    end
  end
end
