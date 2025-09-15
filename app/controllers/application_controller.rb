class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token, only: [:debug_restaurants]

  def debug_restaurants
    restaurants = Restaurant.all.map do |r|
      {
        id: r.id,
        name: r.name,
        slug: r.slug,
        subdomain: r.subdomain,
        deleted_at: r.deleted_at,
        menu_items_count: r.menu_items.count
      }
    end

    render json: {
      total_restaurants: Restaurant.count,
      active_restaurants: Restaurant.active.count,
      restaurants: restaurants
    }
  end

  private

  def authenticate_admin!
    unless admin_logged_in?
      if ENV['RAILWAY_ENVIRONMENT'].present? || ENV['RAILS_ENV'] == 'production'
        # In production, redirect to restaurant-specific login
        if params[:restaurant_slug].present?
          redirect_to restaurant_admin_login_path(restaurant_slug: params[:restaurant_slug])
        else
          # If no restaurant slug, redirect to root
          redirect_to root_path
        end
      else
        redirect_to admin_login_path
      end
    end
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