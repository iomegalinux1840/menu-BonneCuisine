class DebugController < ActionController::Base
  def restaurants
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
      restaurants: restaurants,
      database_connected: ActiveRecord::Base.connected?
    }
  end
end