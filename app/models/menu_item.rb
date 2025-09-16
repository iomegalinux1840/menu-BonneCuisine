class MenuItem < ApplicationRecord
  # Associations
  belongs_to :restaurant

  # Active Storage for image uploads
  has_one_attached :image

  # Validations
  validates :name, presence: true, length: { maximum: 255 }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :position, presence: true

  # Custom image validation (Active Storage validators not loaded in all environments)
  validate :image_format_and_size

  # Scopes
  scope :available, -> { where(available: true) }
  scope :ordered, -> { order(:position) }
  scope :for_restaurant, ->(restaurant) { where(restaurant: restaurant) }

  # Callbacks
  before_validation :set_position, on: :create
  before_save :handle_position_assignment
  after_save :broadcast_menu_update
  after_destroy :broadcast_menu_delete

  private

  def set_position
    return if position.present?

    # Position should be unique per restaurant
    last_position = restaurant.menu_items.maximum(:position) || 0
    self.position = last_position + 1
  end

  def handle_position_assignment
    return unless position_changed?

    # Get the new position value
    new_position = position

    # Shift all other items with position >= new_position down by 1
    # This includes items that currently have the same position
    restaurant.menu_items
              .where('position >= ? AND id != ?', new_position, id)
              .update_all('position = position + 1')
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

  def image_format_and_size
    return unless image.attached?

    # Check file size
    if image.byte_size > 5.megabytes
      errors.add(:image, "ne doit pas dépasser 5MB")
    end

    # Check file type
    unless image.content_type.in?(%w[image/jpeg image/png image/gif image/webp])
      errors.add(:image, "doit être un format d'image valide (JPG, PNG, GIF, WebP)")
    end
  end
end