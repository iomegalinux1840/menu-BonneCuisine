class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  private

  def authenticate_admin!
    redirect_to admin_login_path unless admin_logged_in?
  end

  def admin_logged_in?
    session[:admin_id].present? && current_admin.present?
  end

  def current_admin
    return @current_admin if defined?(@current_admin)

    @current_admin = session[:admin_id] ? Admin.find_by(id: session[:admin_id]) : nil
  end

  helper_method :admin_logged_in?, :current_admin
end