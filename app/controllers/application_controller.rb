class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  helper_method :can_manage?

  def default_url_options
    { host: ENV["DOMAIN"] || "localhost:3000" }
  end

  private

  # Owners can change their own lists and items; admins can change anything.
  def can_manage?(list)
    user_signed_in? && (list.user_id == current_user.id || current_user.admin?)
  end

  def require_owner!(list)
    return if can_manage?(list)

    redirect_back fallback_location: root_path, alert: "You can only change your own lists."
  end

  def require_admin!
    return if current_user&.admin?

    redirect_to root_path, alert: "That page is for admins only."
  end
end
