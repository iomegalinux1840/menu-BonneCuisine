require_relative 'concerns/current_tenant'

class PublicMenusController < ApplicationController
  include CurrentTenant

  skip_before_action :verify_authenticity_token, only: [:index]
  before_action :require_restaurant!
  before_action :apply_restaurant_branding

  layout 'public_menu'

  def index
    Rails.logger.debug "PublicMenusController#index - current_restaurant: #{current_restaurant&.name} (id: #{current_restaurant&.id})"

    @menu_items = current_restaurant.menu_items
                                    .available
                                    .ordered
                                    .limit(12)

    @menu_layout = current_restaurant.layout_settings
    @menu_signature = menu_signature
    @menu_refresh_interval = menu_refresh_interval

    Rails.logger.debug "Found #{@menu_items.count} menu items for restaurant"

    # Debug image attachment status
    @menu_items.each do |item|
      Rails.logger.debug "MenuItem: #{item.name} - Image attached: #{item.image.attached?}"
      if item.image.attached?
        Rails.logger.debug "  Image details: #{item.image.blob.inspect}"
      end
    end

    respond_to do |format|
      format.html do
        # Support for embeddable widget
        if params[:embed] == 'true'
          render layout: 'embed'
        end
      end

      format.json do
        render json: {
          html: render_to_string(
            partial: 'public_menus/menu_content',
            formats: [:html],
            locals: { menu_items: @menu_items, menu_layout: @menu_layout }
          ),
          signature: menu_signature,
          refresh_interval: @menu_refresh_interval
        }
      end
    end
  end

  private

  def menu_signature
    items = current_restaurant.menu_items
    latest = [
      current_restaurant.updated_at,
      items.maximum(:updated_at),
      items.maximum(:created_at)
    ].compact.map { |time| time.utc.to_f }.max

    parts = []
    parts << latest if latest
    parts << items.count
    parts << (items.maximum(:position) || 0)

    parts.present? ? parts.join(':') : '0'
  end

  def menu_refresh_interval
    interval = ENV.fetch('PUBLIC_MENU_REFRESH_INTERVAL_SECONDS', 60).to_i
    interval = 60 if interval <= 0
    interval.clamp(15, 600)
  end

  def apply_restaurant_branding
    @restaurant_branding = {
      name: current_restaurant.name,
      primary_color: current_restaurant.primary_color || '#8B4513',
      secondary_color: current_restaurant.secondary_color || '#F5DEB3',
      font_family: current_restaurant.font_family || 'Playfair Display',
      logo_url: current_restaurant.logo_url
    }
  end
end
