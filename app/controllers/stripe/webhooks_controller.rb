module Stripe
  class WebhooksController < ApplicationController
    skip_before_action :verify_authenticity_token

    def create
      event = construct_event(request)

      handle_event(event)

      render json: { received: true }
    rescue JSON::ParserError, ::Stripe::SignatureVerificationError => e
      Rails.logger.error("[Stripe] Webhook error: #{e.message}")
      head :bad_request
    end

    private

    def construct_event(request)
      payload = request.body.read
      signature = request.headers['Stripe-Signature']
      webhook_secret = ENV['STRIPE_WEBHOOK_SECRET']

      if webhook_secret.present? && signature.present?
        ::Stripe::Webhook.construct_event(payload, signature, webhook_secret)
      else
        data = JSON.parse(payload, symbolize_names: true)
        ::Stripe::Event.construct_from(data)
      end
    end

    def handle_event(event)
      case event.type
      when 'checkout.session.completed'
        handle_checkout_session_completed(event.data.object)
      when 'customer.subscription.updated', 'customer.subscription.deleted'
        handle_customer_subscription_updated(event.data.object)
      else
        Rails.logger.debug("[Stripe] Received unhandled event type: #{event.type}")
      end
    end

    def handle_checkout_session_completed(session)
      subscription = ::Subscription.find_by(stripe_checkout_session_id: session.id)

      unless subscription
        Rails.logger.warn("[Stripe] Subscription not found for session #{session.id}")
        return
      end

      customer_email = session.respond_to?(:customer_details) ? session.customer_details&.email : nil
      customer_id = session.respond_to?(:customer) ? session.customer : nil
      payment_status = session.respond_to?(:payment_status) ? session.payment_status : nil

      subscription.update(
        email: customer_email || subscription.email,
        stripe_customer_id: customer_id || subscription.stripe_customer_id,
        status: payment_status == 'paid' ? 'active' : subscription.status
      )

      attach_subscription_object(subscription, session.subscription)
    end

    def handle_customer_subscription_updated(stripe_subscription)
      subscription = ::Subscription.find_by(stripe_subscription_id: stripe_subscription.id)

      unless subscription
        Rails.logger.warn("[Stripe] Received subscription update for unknown subscription #{stripe_subscription.id}")
        return
      end

      subscription.update_from_stripe_subscription(stripe_subscription)
    end

    def attach_subscription_object(subscription, stripe_subscription_id)
      return if stripe_subscription_id.blank?

      stripe_subscription = retrieve_subscription(stripe_subscription_id)
      return if stripe_subscription.nil?

      subscription.update_from_stripe_subscription(stripe_subscription)
    end

    def retrieve_subscription(subscription_id)
      ::Stripe::Subscription.retrieve(subscription_id)
    rescue ::Stripe::StripeError => e
      Rails.logger.error("[Stripe] Failed to retrieve subscription #{subscription_id}: #{e.message}")
      nil
    end
  end
end
