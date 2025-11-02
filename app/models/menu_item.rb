class MenuItem < ApplicationRecord
  # Associations
  belongs_to :restaurant

  # Active Storage for image uploads
  has_one_attached :image do |attachable|
    # Menu display variants - use conservative operations supported in all environments
    attachable.variant :thumb, resize_to_fill: [150, 150]
    attachable.variant :card, resize_to_fill: [250, 200]
    attachable.variant :medium, resize_to_limit: [400, 300]
    attachable.variant :large, resize_to_limit: [800, 600]
  end

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
  after_commit :broadcast_menu_update, on: [:create, :update]
  after_commit :broadcast_menu_delete, on: :destroy

  # Custom method to handle Active Storage attachment creation
  def create_image_attachment(file)
    return unless file.present?

    Rails.logger.info "Creating image attachment for menu item #{id}"
    Rails.logger.info "File details: #{file.inspect}"

    begin
      # Purge existing image if present
      if image.attached?
        Rails.logger.info "Purging existing image attachment"
        image.purge
      end

      # Attach the new image
      Rails.logger.info "Attaching new image..."
      image.attach(file)
      Rails.logger.info "Image attachment successful: #{image.attached?}"

      if image.attached?
        Rails.logger.info "Image blob details: #{image.blob.inspect}"
        Rails.logger.info "Image blob key: #{image.blob.key}"
      end

    rescue ActiveStorage::IntegrityError => e
      Rails.logger.error "ActiveStorage IntegrityError: #{e.message}"
      Rails.logger.error "File size: #{file.size}, content_type: #{file.content_type}"
      raise e
    rescue ActiveStorage::InvalidError => e
      Rails.logger.error "ActiveStorage InvalidError: #{e.message}"
      raise e
    rescue ActiveStorage::FileNotFoundError => e
      Rails.logger.error "ActiveStorage FileNotFoundError: #{e.message}"
      raise e
    rescue => e
      Rails.logger.error "Unexpected error during image attachment: #{e.class.name} - #{e.message}"
      Rails.logger.error "Backtrace: #{e.backtrace.first(10).join("\n")}"
      raise e
    end
  end

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
    broadcast_menu_refresh
  rescue StandardError => e
    Rails.logger.warn "Broadcasting error: #{e.message}"
  end

  def broadcast_menu_delete
    broadcast_menu_refresh
  rescue StandardError => e
    Rails.logger.warn "Broadcasting error: #{e.message}"
  end

  def broadcast_menu_refresh
    target_restaurant = restaurant || Restaurant.find_by(id: restaurant_id)
    return unless target_restaurant

    MenuChannel.broadcast_to(target_restaurant, { action: "refresh", source: "menu_item" })
  end

  def image_format_and_size
    Rails.logger.info "=== IMAGE VALIDATION START ==="
    Rails.logger.info "Image attached?: #{image.attached?}"
    Rails.logger.info "Image object: #{image.inspect}"

    return unless image.attached?

    begin
      Rails.logger.info "Validating image: #{image.filename}, size: #{image.byte_size}, content_type: #{image.content_type}"

      # Check file size
      if image.byte_size > 5.megabytes
        Rails.logger.warn "Image too large: #{image.byte_size} bytes"
        errors.add(:image, "ne doit pas dépasser 5MB")
      end

      # Check file type - more lenient for now
      allowed_types = %w[image/jpeg image/png image/gif image/webp image/jpg]
      unless image.content_type.in?(allowed_types)
        Rails.logger.warn "Invalid image type: #{image.content_type}"
        errors.add(:image, "doit être un format d'image valide (JPG, PNG, GIF, WebP)")
      end

      # Try to access the blob to see if Active Storage is working
      if image.blob
        Rails.logger.info "Image blob found: #{image.blob.inspect}"
        Rails.logger.info "Blob key: #{image.blob.key}"
        Rails.logger.info "Blob filename: #{image.blob.filename}"
      else
        Rails.logger.warn "No blob found for attached image"
      end

      Rails.logger.info "Image validation completed successfully"
      Rails.logger.info "=== IMAGE VALIDATION END ==="
    rescue ActiveStorage::FileNotFoundError => e
      Rails.logger.error "ActiveStorage FileNotFoundError: #{e.message}"
      errors.add(:image, "Le fichier image n'a pas été trouvé")
    rescue ActiveStorage::IntegrityError => e
      Rails.logger.error "ActiveStorage IntegrityError: #{e.message}"
      errors.add(:image, "L'image est corrompue ou invalide")
    rescue ActiveStorage::InvalidError => e
      Rails.logger.error "ActiveStorage InvalidError: #{e.message}"
      errors.add(:image, "Format d'image non supporté")
    rescue => e
      Rails.logger.error "Image validation error: #{e.message}"
      Rails.logger.error "Image validation backtrace: #{e.backtrace.first(10).join("\n")}"
      Rails.logger.error "Error class: #{e.class.name}"
      Rails.logger.error "=== IMAGE VALIDATION EXCEPTION ==="
      errors.add(:image, "Erreur lors du traitement de l'image: #{e.message}")
    end
  end
end
