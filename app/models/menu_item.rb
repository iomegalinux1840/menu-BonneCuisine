class MenuItem < ApplicationRecord
  validates :name, presence: true, length: { maximum: 255 }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :position, presence: true, uniqueness: true

  scope :available, -> { where(available: true) }
  scope :ordered, -> { order(:position) }

  before_validation :set_position, on: :create

  after_save :broadcast_menu_change
  after_destroy :broadcast_menu_change

  private

  def set_position
    return if position.present?

    last_position = MenuItem.maximum(:position) || 0
    self.position = last_position + 1
  end

  def broadcast_menu_change
    ActionCable.server.broadcast(
      "menu_channel",
      {
        type: "menu_updated",
        menu_items: MenuItem.available.ordered.as_json(
          only: [:id, :name, :description, :price, :comment, :available, :position]
        )
      }
    )
  end
end