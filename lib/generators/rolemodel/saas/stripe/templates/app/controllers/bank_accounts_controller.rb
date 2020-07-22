# frozen_string_literal: true

class BankAccountsController < AuthenticationController
  def edit
    @event_id = params[:event_id]
    @bank_account = authorize BankAccount.create_with(
      name: event_organization.name,
      address: event_organization.address,
      email: event_organization.admin_email,
      remittance_email: event_organization.admin_email
    ).find_or_initialize_by(organization: event_organization)
  end

  def update
    @event_id = params[:event_id]
    @bank_account = authorize BankAccount.find_or_initialize_by(organization_id: event_organization.id)

    if @bank_account.update(bank_account_params)
      redirect_to options_event_path(@event_id), notice: 'Bank account was successfully updated.'
    else
      render :edit
    end
  end

  def event
    Event.find(@event_id)
  end

  def event_organization
    event.organization
  end

  private

  def bank_account_params
    params.require(:bank_account).permit(
      :name,
      :address,
      :email,
      :bank_name,
      :bank_address,
      :account_type,
      :routing_number,
      :account_number,
      :remittance_email
    )
  end
end
