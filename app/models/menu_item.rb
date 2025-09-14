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
  rescue => e
    Rails.logger.warn "Broadcasting error: #{e.message}"
  end

  def broadcast_menu_delete
    # Just send the delete action with the ID
    ActionCable.server.broadcast(
      "menu_channel",
      {
        action: "delete",
        id: self.id
      }
    )
  rescue => e
    Rails.logger.warn "Broadcasting error: #{e.message}"
  end
end