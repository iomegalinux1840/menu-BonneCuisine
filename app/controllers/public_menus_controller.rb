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

    Rails.logger.debug "Found #{@menu_items.count} menu items for restaurant"

    # Debug image attachment status
    @menu_items.each do |item|
      Rails.logger.debug "MenuItem: #{item.name} - Image attached: #{item.image.attached?}"
      if item.image.attached?
        Rails.logger.debug "  Image details: #{item.image.blob.inspect}"
      end
    end

    # Support for embeddable widget
    if params[:embed] == 'true'
      render layout: 'embed'
    end
  end

  private

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
