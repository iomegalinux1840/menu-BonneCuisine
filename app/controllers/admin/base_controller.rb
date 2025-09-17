class Admin::BaseController < ApplicationController
  layout 'admin'

  before_action :authenticate_admin!
  before_action :load_restaurant_from_slug

  private

  def load_restaurant_from_slug
    @restaurant = Restaurant.active.find_by(slug: params[:restaurant_slug])

    unless @restaurant
      Rails.logger.error "Restaurant not found for admin: #{params[:restaurant_slug]}"
      respond_to do |format|
        format.html { render plain: "404 Restaurant Not Found", status: :not_found }
        format.json { render json: { error: 'Restaurant not found' }, status: :not_found }
      end
      return
    end

    if current_admin && current_admin.restaurant_id != @restaurant.id
      redirect_to root_path, alert: 'Access denied'
    end
  end
end
