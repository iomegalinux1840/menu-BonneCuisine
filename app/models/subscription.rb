class Subscription < ApplicationRecord
  STATUSES = %w[
    pending
    trialing
    active
    past_due
    canceled
    incomplete
    incomplete_expired
    unpaid
  ].freeze

  belongs_to :restaurant

  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :stripe_checkout_session_id, presence: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  scope :active, -> { where(status: 'active') }

  def update_from_stripe_subscription(stripe_subscription)
    period_end = if stripe_subscription.respond_to?(:current_period_end) && stripe_subscription.current_period_end.present?
      Time.at(stripe_subscription.current_period_end).in_time_zone
    end

    update(
      stripe_subscription_id: stripe_subscription.id,
      stripe_customer_id: stripe_subscription.customer,
      status: normalize_status(stripe_subscription.status),
      current_period_end: period_end,
      metadata: (metadata || {}).merge(stripe_subscription.metadata || {})
    )
  end

  private

  def normalize_status(stripe_status)
    return 'pending' if stripe_status.blank?

    mapped_status = stripe_status.to_s

    STATUSES.include?(mapped_status) ? mapped_status : 'pending'
  end
end
