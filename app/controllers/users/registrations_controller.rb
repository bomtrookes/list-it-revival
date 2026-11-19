# Only the "edit my account" part of Devise registrations is used.
# Sign-up and account deletion are switched off (see config/routes.rb).
class Users::RegistrationsController < Devise::RegistrationsController
  before_action :block_demo_user, only: [:edit, :update]

  protected

  def account_update_params
    params.require(:user).permit(:username, :email, :bio, :avatar, :password, :password_confirmation, :current_password)
  end

  def after_update_path_for(resource)
    user_path(resource)
  end

  private

  def block_demo_user
    return unless current_user&.demo?

    redirect_to user_path(current_user), alert: "The demo account's settings can't be changed."
  end
end
