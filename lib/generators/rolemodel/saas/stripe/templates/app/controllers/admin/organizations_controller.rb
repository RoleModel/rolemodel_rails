# frozen_string_literal: true

class Admin::OrganizationsController < AuthenticationController

  def index
    authorize current_user.organization
    @sort = params[:sort]
    sort_direction = params[:sort_direction] || :asc
    @sort_direction = sort_direction.to_sym
    query = Organization.includes(:users, :subscriptions, :events)
    if @sort == 'start_date'
      @organizations = query.references(:events).merge(Event.order(start_date: @sort_direction))
    elsif %w(status paid_through_date next_billing_date plan_category).include?(@sort)
      @organizations = query.references(:subscriptions).merge(Subscription.order(@sort => @sort_direction))
    else
      @organizations = query.order(name: @sort_direction)
    end
  end

  def show
    @organization = Organization.includes(:subscriptions, :users, :events).references(:events).merge(Event.order(start_date: :desc)).find(params[:id])
    if @organization.gateway_customer_path && current_user.support_admin?
      @action = { title: 'Stripe', path: @organization.gateway_customer_path }
    end
    authorize @organization
  end
end
