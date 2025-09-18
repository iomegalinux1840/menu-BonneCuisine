require_relative 'concerns/current_tenant'

class SubscriptionsController < ApplicationController
  include CurrentTenant

  before_action :require_restaurant!

  def create
    unless stripe_configured?
      render json: { error: I18n.t('subscriptions.errors.misconfigured') }, status: :unprocessable_entity
      return
    end

    price_id = price_id_for_restaurant

    if price_id.blank?
      render json: { error: I18n.t('subscriptions.errors.missing_price') }, status: :unprocessable_entity
      return
    end

    checkout_session = Stripe::Checkout::Session.create(
      mode: 'subscription',
      success_url: restaurant_subscriptions_success_url(restaurant_slug: current_restaurant.slug) + '?session_id={CHECKOUT_SESSION_ID}',
      cancel_url: restaurant_subscriptions_cancel_url(restaurant_slug: current_restaurant.slug),
      customer_creation: 'always',
      line_items: [
        {
          price: price_id,
          quantity: 1
        }
      ],
      metadata: {
        restaurant_id: current_restaurant.id
      }
    )

    subscription = current_restaurant.subscriptions.create!(
      stripe_checkout_session_id: checkout_session.id,
      price_id: price_id,
      status: 'pending'
    )

    render json: { id: checkout_session.id, subscription_id: subscription.id }
  rescue Stripe::StripeError => e
    Rails.logger.error("[Stripe] Checkout session creation failed: #{e.message}")
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def success
    @subscription = Subscription.find_by(stripe_checkout_session_id: params[:session_id]) if params[:session_id].present?
  end

  def cancel
  end

  private

  def stripe_configured?
    ENV['STRIPE_SECRET_KEY'].present? && ENV['STRIPE_PUBLISHABLE_KEY'].present?
  end

  def price_id_for_restaurant
    current_restaurant.stripe_price_id.presence || ENV['STRIPE_PRICE_ID']
  end
end
