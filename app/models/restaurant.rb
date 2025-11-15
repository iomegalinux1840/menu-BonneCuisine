# :reek:TooManyMethods
class Restaurant < ApplicationRecord
  # Associations
  has_many :menu_items, dependent: :destroy
  has_many :admins, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  MENU_IMAGE_SIZES = %w[small large].freeze
  MENU_GRID_COLUMN_RANGE = (3..6).freeze
  MENU_DISPLAY_STYLES = %w[classic showcase].freeze
  MENU_FONT_SIZES = %w[small medium large].freeze

  # Validations
  validates :name, presence: true, length: { maximum: 100 }
  validates :slug, presence: true, uniqueness: true,
            format: { with: /\A[a-z0-9-]+\z/, message: "only lowercase letters, numbers and hyphens" },
            length: { minimum: 3, maximum: 50 }
  validates :subdomain, uniqueness: { allow_blank: true },
            format: { with: /\A[a-z0-9-]+\z/, message: "only lowercase letters, numbers and hyphens" },
            length: { minimum: 3, maximum: 50 },
            allow_blank: true
  validates :custom_domain, uniqueness: { allow_blank: true },
            format: { with: /\A[a-z0-9.-]+\z/, message: "invalid domain format" },
            allow_blank: true
  validates :menu_image_size, inclusion: { in: MENU_IMAGE_SIZES }
  validates :menu_grid_columns, inclusion: { in: MENU_GRID_COLUMN_RANGE }
  validates :menu_display_style, inclusion: { in: MENU_DISPLAY_STYLES }
  validates :menu_font_size, inclusion: { in: MENU_FONT_SIZES }
  validates :menu_font_color, :menu_background_color, :menu_accent_color,
            format: { with: /\A#(?:[0-9a-fA-F]{3}|[0-9a-fA-F]{6})\z/,
                      message: "doit être un code couleur hexadécimal valide" }

  # Reserved subdomains that cannot be used
  RESERVED_SUBDOMAINS = %w[
    www admin api app assets help support docs
    blog mail email ftp ssh test dev staging
    production demo portal dashboard login signup
    register account billing payment
  ].freeze

  validate :subdomain_not_reserved

  # Callbacks
  before_validation :generate_slug, on: :create
  before_validation :normalize_fields
  before_validation :normalize_menu_colors

  # Scopes
  scope :active, -> { where(deleted_at: nil) }
  scope :deleted, -> { where.not(deleted_at: nil) }

  # Default values
  after_initialize :set_defaults, if: :new_record?
  after_commit :broadcast_menu_layout_update, if: :menu_layout_changed?

  # Soft delete
  def soft_delete!
    update!(deleted_at: Time.current)
  end

  def deleted?
    deleted_at.present?
  end

  def restore!
    update!(deleted_at: nil)
  end

  # URL helpers
  def display_domain
    custom_domain || subdomain_with_base || slug_with_base
  end

  def subdomain_with_base
    return nil unless subdomain.present?
    "#{subdomain}.#{base_domain}"
  end

  def slug_with_base
    "#{base_domain}/#{slug}"
  end

  def layout_settings
    {
      image_size: menu_image_size.presence || 'small',
      grid_columns: menu_grid_columns.presence || 3,
      message_of_the_day: message_of_the_day,
      display_style: menu_display_style.presence || 'classic',
      font_size: menu_font_size.presence || 'medium',
      font_color: menu_font_color.presence || '#f8fafc',
      background_color: menu_background_color.presence || '#0f172a',
      accent_color: menu_accent_color.presence || '#facc15'
    }
  end

  private

  def menu_layout_changed?
    saved_change_to_menu_image_size? ||
      saved_change_to_menu_grid_columns? ||
      saved_change_to_message_of_the_day? ||
      saved_change_to_menu_display_style? ||
      saved_change_to_menu_font_size? ||
      saved_change_to_menu_font_color? ||
      saved_change_to_menu_background_color? ||
      saved_change_to_menu_accent_color?
  end

  def broadcast_menu_layout_update
    MenuChannel.broadcast_to(self, { action: "refresh", source: "layout" })
  rescue StandardError => e
    Rails.logger.warn "Layout broadcast failed: #{e.message}"
  end

  def base_domain
    ENV.fetch('BASE_DOMAIN', 'menuplatform.app')
  end

  def generate_slug
    return if slug.present?

    base = name.downcase.gsub(/[^a-z0-9]+/, '-').gsub(/^-|-$/, '')
    candidate = base
    counter = 2

    while Restaurant.exists?(slug: candidate)
      candidate = "#{base}-#{counter}"
      counter += 1
    end

    self.slug = candidate
  end

  def normalize_fields
    self.slug = slug&.downcase&.strip
    self.subdomain = subdomain&.downcase&.strip
    self.custom_domain = custom_domain&.downcase&.strip
  end

  def subdomain_not_reserved
    return unless subdomain.present?

    if RESERVED_SUBDOMAINS.include?(subdomain.downcase)
      errors.add(:subdomain, "is reserved and cannot be used")
    end
  end

  def set_defaults
    self.primary_color ||= '#8B4513'
    self.secondary_color ||= '#F5DEB3'
    self.font_family ||= 'Playfair Display'
    self.timezone ||= 'America/Toronto'
    self.menu_image_size ||= 'small'
    self.menu_grid_columns ||= 3
    self.menu_display_style ||= 'showcase'
    self.menu_font_size ||= 'medium'
    self.menu_font_color ||= '#F8FAFC'
    self.menu_background_color ||= '#0F172A'
    self.menu_accent_color ||= '#FACC15'
  end

  def normalize_menu_colors
    normalizer_owner = self.class
    self.menu_font_color = normalizer_owner.normalize_color_value(menu_font_color)
    self.menu_background_color = normalizer_owner.normalize_color_value(menu_background_color)
    self.menu_accent_color = normalizer_owner.normalize_color_value(menu_accent_color)
  end

  def self.normalize_color_value(value)
    return nil if value.blank?

    sanitized = value.to_s.strip
    sanitized = "##{sanitized}" unless sanitized.start_with?('#')
    sanitized.upcase
  end
end
