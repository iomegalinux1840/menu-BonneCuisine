# frozen_string_literal: true

if ENV['STRIPE_SECRET_KEY'].present?
  require 'stripe'

  Stripe.api_key = ENV['STRIPE_SECRET_KEY']
  Stripe.api_version = '2023-10-16'
  Stripe.max_network_retries = 2
else
  Rails.logger.warn('[Stripe] STRIPE_SECRET_KEY is not set; Stripe API calls will fail')
end
