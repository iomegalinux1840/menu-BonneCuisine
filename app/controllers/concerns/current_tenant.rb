module CurrentTenant
  extend ActiveSupport::Concern

  included do
    before_action :set_current_restaurant
    helper_method :current_restaurant
  end

  private

  def set_current_restaurant
    @current_restaurant = find_restaurant_from_request

    # If no restaurant found and we're not on the main domain, show 404
    if @current_restaurant.nil? && !on_main_domain?
      render_restaurant_not_found
    end
  end

  def current_restaurant
    @current_restaurant
  end

  def find_restaurant_from_request
    # Priority order:
    # 1. Subdomain (e.g., restaurant-a.menuplatform.app)
    # 2. Custom domain (e.g., menu.restaurant-a.com)
    # 3. Path-based slug (e.g., menuplatform.app/r/restaurant-a)
    # 4. Restaurant ID in session (for admin area)

    restaurant = find_by_subdomain ||
                 find_by_custom_domain ||
                 find_by_path_slug ||
                 find_by_session

    # Ensure restaurant is active (not soft-deleted)
    restaurant&.deleted? ? nil : restaurant
  end

  def find_by_subdomain
    return nil if request.subdomain.blank? || reserved_subdomain?

    Restaurant.active.find_by(subdomain: request.subdomain)
  end

  def find_by_custom_domain
    return nil if on_main_domain?

    Restaurant.active.find_by(custom_domain: request.host)
  end

  def find_by_path_slug
    # Check if we're on a path like /r/restaurant-slug
    if params[:restaurant_slug].present?
      Restaurant.active.find_by(slug: params[:restaurant_slug])
    end
  end

  def find_by_session
    # For admin areas, we might store restaurant_id in session
    if session[:restaurant_id].present?
      Restaurant.active.find_by(id: session[:restaurant_id])
    end
  end

  def on_main_domain?
    # Check if we're on the main platform domain without subdomain
    base_domain = ENV.fetch('BASE_DOMAIN', 'localhost')
    request.host == base_domain && request.subdomain.blank?
  end

  def reserved_subdomain?
    # List of subdomains reserved for platform use
    reserved = %w[www admin api app assets help support docs]
    reserved.include?(request.subdomain)
  end

  def require_restaurant!
    unless current_restaurant
      render_restaurant_not_found
    end
  end

  def render_restaurant_not_found
    respond_to do |format|
      format.html do
        render file: Rails.public_path.join('404.html'),
               status: :not_found,
               layout: false
      end
      format.json do
        render json: { error: 'Restaurant not found' }, status: :not_found
      end
    end
  end

  # Helper method to generate URLs with proper subdomain
  def restaurant_url(restaurant, path = '/')
    if restaurant.custom_domain.present?
      "#{request.protocol}#{restaurant.custom_domain}#{path}"
    elsif restaurant.subdomain.present?
      "#{request.protocol}#{restaurant.subdomain}.#{ENV.fetch('BASE_DOMAIN', 'localhost:3000')}#{path}"
    else
      "#{request.protocol}#{ENV.fetch('BASE_DOMAIN', 'localhost:3000')}/r/#{restaurant.slug}#{path}"
    end
  end
end