class Admin < ApplicationRecord
  # Associations
  belongs_to :restaurant

  # Authentication
  has_secure_password

  # Validations
  validates :email, presence: true,
            uniqueness: { scope: :restaurant_id, message: "already exists for this restaurant" },
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
  validates :role, inclusion: { in: %w[owner manager staff], message: "must be owner, manager, or staff" }

  # Scopes
  scope :owners, -> { where(role: 'owner') }
  scope :managers, -> { where(role: 'manager') }
  scope :staff, -> { where(role: 'staff') }

  # Callbacks
  before_validation :set_default_role, on: :create
  after_create :ensure_restaurant_has_owner

  # Class methods
  def self.authenticate_for_restaurant(restaurant, email, password)
    admin = restaurant.admins.find_by(email: email)
    return nil unless admin&.authenticate(password)

    admin.update_column(:last_login_at, Time.current)
    admin
  end

  # Instance methods
  def owner?
    role == 'owner'
  end

  def manager?
    role == 'manager'
  end

  def staff?
    role == 'staff'
  end

  def can_manage_admins?
    owner? || manager?
  end

  def can_edit_settings?
    owner?
  end

  private

  def set_default_role
    self.role ||= 'manager'
  end

  def ensure_restaurant_has_owner
    # If this is the first admin for the restaurant, make them an owner
    if restaurant.admins.count == 1
      update_column(:role, 'owner')
    end
  end
end