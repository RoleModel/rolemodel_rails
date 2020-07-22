# frozen_string_literal: true

class OrganizationInvitationsController < AuthenticationController
  before_action :skip_authorization, only: [:index]

  def index # case: handles refresh of new form after flash message displayed
    redirect_to new_organization_invitation_path
  end

  def new
    @organization = Organization.new
    authorize @organization
    if !current_organization.has_credits? && !current_user.support_admin?
      flash[:notice] = 'Sorry, you are out of credits.'
      return redirect_to after_invite_path
    end
  end

  def create
    if params[:commit] == 'Cancel'
      return redirect_to after_invite_path
    end
    if !current_user.support_admin?
      authorize current_organization, :update?
      try_to_spend_credit
    end
    @organization = Organization.new(organization_params)
    @organization.add_credits(@organization.subscriptions.first)
    authorize @organization
    authorize @organization.users.first
    authorize @organization.subscriptions.first
    return render :new if invalid?(@organization)

    flash[:notice] = @organization.users.first.name + ' (invited)'
    @organization.users.destroy_all # don't save the User, just invite them
    @organization.save
    User.invite!(organization_params[:users_attributes]['0'].merge(organization: @organization))
    return redirect_to after_invite_path
  end

  private

  def after_invite_path
    if current_user.support_admin?
      admin_organizations_path
    else
      organization_path
    end
  end

  def organization_params
    params.require(:organization).permit(
      :name,
      users_attributes: [
        :name,
        :email
      ],
      subscriptions_attributes: [
        :plan_category,
        :paid_through_date
      ]
    ).to_h.tap do |hash|
      plan_category = 'SubscriptionPlan::' + hash[:subscriptions_attributes]['0'][:plan_category].sub(' ','')
      hash[:subscriptions_attributes]['0'][:plan_category] = plan_category
      hash[:subscriptions_attributes]['0'][:status] = 'Invited'
      hash[:users_attributes]['0'][:role] = 'org_admin'
      hash[:name] = hash[:users_attributes]['0'][:name] if plan_category == 'SubscriptionPlan::Participant'
    end
  end

  def try_to_spend_credit
    if current_organization.has_credits?
      current_organization.tap(&:spend_credit).save
    else
      flash[:notice] = 'Sorry, you are out of credits.'
      return redirect_to after_invite_path
    end
  end

  def invalid?(organization)
    organization.valid?
    ignored_messages = [
      "Users password can't be blank",
      "Users agreed to terms on Please agree to the terms and conditions before continuing",
      "Name can't be blank" # duplicate of validation on organization
    ]
    ignored_messages.push("Users organization name can't be blank") unless current_user.support_admin?
    errors = organization.errors.full_messages.delete_if do |message|
      ignored_messages.include?(message)
    end
    if errors.any?
      flash.now[:notice] = errors.to_sentence
      return true
    end
  end
end
