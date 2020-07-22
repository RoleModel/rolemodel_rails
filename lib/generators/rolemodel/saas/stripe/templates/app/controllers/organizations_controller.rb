# frozen_string_literal: true

class OrganizationsController < AuthenticationController
  before_action :set_organization

  def show
    day_of_subscription_extension = Date.new(2020, 3, 27)
    subscription_update = @organization.active_subscription.updated_at
    covid_19_notice = 'All Ninja Master Subscriptions have been extended by 3 months as of March 26,2020 due to impacts to gyms because of COVID-19'
    flash[:notice] = flash[:notice] || covid_19_notice if subscription_update && (subscription_update <= day_of_subscription_extension)
    @max_user_count = @organization.max_user_count
    @user_count = @organization.users.to_a.size
    @invitable_user_count = @max_user_count - @user_count
    @deactivated_users = @organization.users.only_deleted
    @action = { title: 'Gift Subscription', path: new_organization_invitation_path } if @organization.has_credits? || current_user.support_admin?
  end

  def edit; end

  def update
    if @organization.update(organization_params)
      redirect_to organization_url, notice: 'Organization successfully updated'
    else
      flash.now[:notice] = @organization.errors.full_messages.to_sentence
      render :edit
    end
  end

  private

  def organization_params
    params.require(:organization).permit(:name, :address, :url, :description)
  end

  def set_organization
    @organization = authorize current_organization
  end
end
