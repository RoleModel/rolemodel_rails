# frozen_string_literal: true

module Admin
  class UsersController < ApplicationController
    def index
      @users = User.all
    end

    def edit
      @user = User.find(params[:id])
    end

    def update
      @user = User.find(params[:id])
      if @user.update(user_params)
        redirect_to admin_users_url, notice: 'User was updated successfully'
      else
        render :edit
      end
    end
<%- if @add_invitations %>
    def reinvite
      @user = User.find(params[:id])
      @user.invite! current_user
      redirect_to admin_users_url, notice: 'Invitation email sent'
    end
<%- end %>
    private

    def user_params
      params.require(:user).permit(:email, :first_name, :last_name)
    end
  end
end
