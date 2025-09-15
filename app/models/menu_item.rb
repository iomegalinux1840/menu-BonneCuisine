class MenuItem < ApplicationRecord
  # Associations
  belongs_to :restaurant

  # Active Storage for image uploads
  has_one_attached :image do |attachable|
    attachable.variant :thumb, resize_to_limit: [200, 200]
    attachable.variant :medium, resize_to_limit: [400, 400]
    attachable.variant :large, resize_to_limit: [800, 600]
  end

  # Validations
  validates :name, presence: true, length: { maximum: 255 }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :position, presence: true, uniqueness: { scope: :restaurant_id }
  validates :image, content_type: { in: %w[image/jpeg image/gif image/png image/webp],
                                    message: "doit être un format d'image valide" },
                    size: { less_than: 5.megabytes, message: "ne doit pas dépasser 5MB" }

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