# frozen_string_literal: true

class Users::InvitationsController < Devise::InvitationsController
  before_action :configure_invite_params, only: [:create]
  before_action :configure_accept_invitation_params, only: [:update]

  # GET /resource/invitation/new
  def new
    return redirect_to root_url unless current_user.org_admin? || current_user.support_admin?

    @organization = Organization.find(params[:organization_id]) if params[:organization_id]
    super
  end

  # POST /resource/invitation
  # def create
  # end

  # GET /resource/invitation/accept?invitation_token=abcdef
  # def edit
  # end

  # PUT /resource/invitation
  # def update
  #   super do |user|
  #     status = user.organization.current_subscription.status
  #     user.organization.current_subscription.update(status: 'Active') if status == 'Invited'
  #   end
  # end

  # GET /resource/invitation/remove?invitation_token=abcdef
  # def destroy
  # end

  # protected

  # this is called when creating invitation
  # should return an instance of resource class
  # def invite_resource(&block)
  #   # If there's an existing user which is deactivated, go ahead and reactivate them.
  #   User.with_deleted.find_by(email: invite_params[:email])&.restore!
  #   super
  # end

  # this is called when accepting invitation
  # should return an instance of resource class
  # def accept_resource
  # end

  private

  def configure_invite_params
    devise_parameter_sanitizer.permit(:invite, keys: %i[first_name last_name email organization_id])
  end

  def invite_params
    super.tap do |hash|
      # if current_user.org_admin? && !current_user.support_admin?
        hash[:organization_id] = current_user.organization_id
      # end
    end
  end

  def configure_accept_invitation_params
    devise_parameter_sanitizer.permit(:accept_invitation, keys: %i[first_name last_name password password_confirmation])
  end

  # After an invitation is created and sent, the inviter will be redirected to
  # def after_invite_path_for(inviter, invitee = nil)
  #   organization = invitee.try(:organization) || Organization.find(params[:user][:organization_id])
  #   inviter.support_admin? ? admin_organization_path(organization) : organization_path(organization)
  # end

  # After an invitation is accepted, the invitee will be redirected to
  # def after_accept_path_for(invitee)
  # end
end
