class MenuItem < ApplicationRecord
  validates :name, presence: true, length: { maximum: 255 }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :position, presence: true, uniqueness: true

  scope :available, -> { where(available: true) }
  scope :ordered, -> { order(:position) }

  before_validation :set_position, on: :create

  after_save :broadcast_menu_update
  after_destroy :broadcast_menu_delete

  private

  def set_position
    return if position.present?

    last_position = MenuItem.maximum(:position) || 0
    self.position = last_position + 1
  end

  def broadcast_menu_update
    # Skip broadcasting if Redis is not available (e.g., during seeding)
    return unless redis_available?

    # Get all available menu items
    menu_items = MenuItem.available.ordered.limit(12)

    # Render the HTML for the menu items
    renderer = ApplicationController.renderer.new
    html = menu_items.map do |item|
      renderer.render(partial: 'menu_items/menu_item', locals: { menu_item: item })
    end.join

    # Broadcast the update
    ActionCable.server.broadcast(
      "menu_channel",
      {
        action: "update",
        html: html
      }
    )
  rescue Redis::CannotConnectError => e
    Rails.logger.warn "Redis not available for broadcasting: #{e.message}"
  end

  def broadcast_menu_delete
    # Skip broadcasting if Redis is not available
    return unless redis_available?

    # Just send the delete action with the ID
    ActionCable.server.broadcast(
      "menu_channel",
      {
        action: "delete",
        id: self.id
      }
    )
  rescue Redis::CannotConnectError => e
    Rails.logger.warn "Redis not available for broadcasting: #{e.message}"
  end

  def redis_available?
    # Check if Redis is configured and available
    return false if Rails.env.production? && ENV['REDIS_URL'].blank?
    true
  end
end