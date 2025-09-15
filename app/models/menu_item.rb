class MenuItem < ApplicationRecord
  # Associations
  belongs_to :restaurant

  # Active Storage for image uploads
  has_one_attached :image

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
    # Broadcast simple update notification instead of rendering HTML
    # This avoids potential rendering issues in production
    ActionCable.server.broadcast(
      "menu_channel_#{restaurant.id}",
      {
        action: "update",
        menu_item_id: self.id
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