# frozen_string_literal: true

class EventsController < AuthenticationController
  before_action :set_event, except: %i[index manage new create]

  def index
    @events = current_user.participant_events.by_newest_start_date.joins(:courses).includes(:courses)
    authorize Event
  end

  def manage
    @events = current_user.events.by_newest_start_date
    authorize @events
  end

  def new
    @event = Event.new(
      organization: current_user.try(:organization),
      default_rule_set: RuleSet::AWG.to_s,
      tag_config: RuleSet::AWG.new.default_tag_config,
      start_date: Date.current,
      end_date: Date.current + 1.day
    )
    authorize @event
  end

  def edit
    @course_id = @event.courses.first.id if @event.courses.any?
  end

  # Not needed: here so people know the action exists
  def options; end

  def contestants_summary; end

  def registration_orders
    @registration_orders = @event.registration_orders.paid.order_by_user_names
  end

  def contestants_summary_csv
    exporter = Utils::CSVExporter.contestants(@event)
    send_data exporter.csv_string, filename: 'contestants_summary.csv', type: 'application/csv'
  end

  def spectators_summary_csv
    exporter = Utils::CSVExporter.spectators(@event)
    send_data exporter.csv_string, filename: 'spectators_summary.csv', type: 'application/csv'
  end

  def spectators_summary
    @exporter = Utils::CSVExporter.spectators(@event)
  end

  def publicize
    # TODO: this should probably be getting created when even is getting created
    # will need migration for old events that don't have one
    @event_registration_info = EventRegistrationInfo.find_or_initialize_by(event: @event)

    return unless @event_registration_info.new_record?

    @event_registration_info.update(description: @event_registration_info.default_description)
  end

  def configure_tickets
    # TODO: this should probably be getting created when even is getting created
    # will need migration for old events that don't have one
    @event_registration_info = EventRegistrationInfo.find_or_initialize_by(event: @event)

    return unless @event_registration_info.new_record?

    @event_registration_info.update(description: @event_registration_info.default_description)
  end

  def create
    @event = Event.new(event_params.merge(organization: current_organization))
    authorize @event

    course = @event.courses.build(name: 'Stage 1', rule_set: @event.default_rule_set)

    if @event.save
      redirect_to event_courses_path(@event), notice: 'Event was successfully created'
    else
      render :new
    end
  end

  def update
    if @event.update(event_params)
      respond_to do |format|
        format.html { redirect_to event_courses_path(@event), notice: 'Event was successfully updated.' }
        format.json { head :ok }
      end
    else
      render :edit
    end
  end

  def destroy
    @event.destroy

    if @event.errors.any?
      redirect_to manage_events_path, notice: @event.errors.full_messages.join(', ')
    else
      redirect_to manage_events_path, notice: 'Event was successfully deleted.'
    end
  end

  private

  def set_event
    @event = Event.find(params[:id])
    authorize @event
  end

  def event_params
    if current_organization.active_subscription.virtual_events?
      all_params = params.require(:event).permit(base_params.concat(additional_params))
    else
      all_params = params.require(:event).permit(base_params)
    end

    all_params.merge!(start_date: Date.strptime(all_params[:start_date], "%m/%d/%Y")) if all_params[:start_date]
    all_params.merge!(end_date: Date.strptime(all_params[:end_date], "%m/%d/%Y")) if all_params[:end_date]
    all_params
  end

  def base_params
    [
      :name,
      :start_date,
      :end_date,
      :obstacles,
      :description,
      :address,
      :photo,
      :default_rule_set,
      :enable_registration,
      :sanction_id,
      tag_config: {}
    ]
  end

  def additional_params
    [
      :virtual,
      organization_attributes: [
        :name,
        :address,
        :url,
        :description
      ]
    ]
  end
end
