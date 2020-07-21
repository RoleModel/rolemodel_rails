# frozen_string_literal: true

class Users::InvitationsController < Devise::InvitationsController
  before_action :params_for_invite, only: [:create, :invite_admin]
  before_action :params_for_accept, only: [:update]

  def new
    @organization = Organization.find(params[:organization_id])
    super
  end

  def create
    if params[:commit] == 'Cancel'
      return redirect_to after_invite_path_for(current_user)
    end
    @organization = Organization.find(params[:user][:organization_id])
    if @organization.out_of_invites?
      flash[:notice] = 'You have reached the maximum number of users for this organization.'
      return redirect_to after_invite_path_for(current_user)
    end
    super do |user|
      if !user.valid? && (user.errors[:name].present? || user.errors[:email].present?)
        flash.now[:notice] = [
          user.errors.full_messages_for(:name),
          user.errors.full_messages_for(:email)
        ].flatten.to_sentence
      end
    end
  end

  def update
    super do |user|
      status = user.organization.active_subscription.status
      user.organization.active_subscription.update(status: 'Active') if status == 'Invited'
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :organization_id).to_h.tap do |hash|
      hash[:role] = 'org_admin'
    end
  end

  def params_for_invite
    devise_parameter_sanitizer.permit(:invite, keys: [:name, :email, :organization_id])
  end

  def params_for_accept
    devise_parameter_sanitizer.permit(:accept_invitation, keys: [:name, :password, :password_confirmation, :agreed_to_terms_on])
  end

  def after_invite_path_for(inviter, invitee = nil)
    organization = invitee.try(:organization) || Organization.find(params[:user][:organization_id])
    inviter.support_admin? ? admin_organization_path(organization) : organization_path(organization)
  end

  # def after_accept_path_for(invitee)
  #   events_path
  # end

  def invite_resource(&block)
    # If there's an existing user which is deactivated, go ahead and reactivate them.
    User.with_deleted.find_by(email: invite_params[:email])&.restore!
    super
  end
end
