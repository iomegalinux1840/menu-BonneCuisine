class MenuItem < ApplicationRecord
  # Associations
  belongs_to :restaurant

  # Validations
  validates :name, presence: true, length: { maximum: 255 }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :position, presence: true, uniqueness: { scope: :restaurant_id }

  # Scopes
  scope :available, -> { where(available: true) }
  scope :ordered, -> { order(:position) }
  scope :for_restaurant, ->(restaurant) { where(restaurant: restaurant) }

  # Callbacks
  before_validation :set_position, on: :create
  after_save :broadcast_menu_update
  after_destroy :broadcast_menu_delete

  private

  def set_position
    return if position.present?

    # Position should be unique per restaurant
    last_position = restaurant.menu_items.maximum(:position) || 0
    self.position = last_position + 1
  end

  def broadcast_menu_update
    # Get all available menu items for this restaurant
    menu_items = restaurant.menu_items.available.ordered.limit(12)

    # Render the HTML for the menu items
    renderer = ApplicationController.renderer.new
    html = menu_items.map do |item|
      renderer.render(partial: 'menu_items/menu_item', locals: { menu_item: item })
    end.join

    # Broadcast the update with restaurant-specific channel
    ActionCable.server.broadcast(
      "menu_channel_#{restaurant.id}",
      {
        action: "update",
        html: html
      }
    )
  rescue => e
    Rails.logger.warn "Broadcasting error: #{e.message}"
  end

  def broadcast_menu_delete
    # Send delete action with restaurant-specific channel
    ActionCable.server.broadcast(
      "menu_channel_#{restaurant.id}",
      {
        action: "delete",
        id: self.id
      }
    )
  rescue => e
    Rails.logger.warn "Broadcasting error: #{e.message}"
  end
end