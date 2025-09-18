class RestaurantsController < ApplicationController
  before_action :ensure_price_configured, only: :create
  before_action :set_restaurant, only: [:setup, :complete_setup]

  def new
    @restaurant = Restaurant.new
    @admin = Admin.new
    session.delete(:pending_admin_id)
    session.delete(:pending_restaurant_id)
  end

  def create
    @restaurant = Restaurant.new(restaurant_params)
    @admin = Admin.new(admin_params)

    unless assign_stripe_defaults(@restaurant)
      render :new, status: :unprocessable_entity
      return
    end

    unless @restaurant.valid? && @admin.valid?
      # Ensure validation errors are available to the view
      @restaurant.valid?
      @admin.valid?
      render :new, status: :unprocessable_entity
      return
    end

    checkout_session = nil
    ActiveRecord::Base.transaction do
      @restaurant.save!
      @admin.restaurant = @restaurant
      @admin.save!

      checkout_session = create_trial_checkout_session(@restaurant, @admin)

      @restaurant.subscriptions.create!(
        email: @admin.email,
        stripe_checkout_session_id: checkout_session.id,
        price_id: selected_price_id,
        status: 'pending'
      )

      @restaurant.update!(subscription_status: 'pending', stripe_price_id: selected_price_id)

      session[:pending_admin_id] = @admin.id
      session[:pending_restaurant_id] = @restaurant.id
    end

    redirect_to checkout_session.url, allow_other_host: true, status: :see_other
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("[Signup] Record invalid: #{e.record.class} - #{e.record.errors.full_messages.join(', ')}")
    render :new, status: :unprocessable_entity
  rescue Stripe::StripeError => e
    Rails.logger.error("[Stripe] Trial signup failed: #{e.message}")
    @restaurant.errors.add(:base, "Impossible de démarrer l'essai Stripe : #{e.message}")
    render :new, status: :unprocessable_entity
  end

  def setup
    @subscription = @restaurant.subscriptions.order(created_at: :desc).first

    if params[:session_id].present? && @subscription&.stripe_checkout_session_id == params[:session_id]
      begin
        session_object = Stripe::Checkout::Session.retrieve(params[:session_id])
        @customer_email = session_object.customer_details&.email
        attach_subscription_if_ready(@subscription, session_object)
      rescue Stripe::StripeError => e
        Rails.logger.error("[Stripe] Unable to refresh checkout session #{params[:session_id]}: #{e.message}")
        flash.now[:alert] = "Nous n'avons pas pu vérifier le statut Stripe. Votre essai reste en attente."
      end
    end

    auto_login_pending_admin
  end

  def complete_setup
    @restaurant.update(restaurant_setup_params)
    redirect_to restaurant_admin_menu_items_path(restaurant_slug: @restaurant.slug), notice: 'Votre menu est prêt à être personnalisé.'
  end

  private

  def restaurant_params
    params.require(:restaurant).permit(:name, :primary_color, :secondary_color, :timezone)
  end

  def restaurant_setup_params
    params.require(:restaurant).permit(:message_of_the_day)
  end

  def admin_params
    params.require(:admin).permit(:email, :password, :password_confirmation)
  end

  def ensure_price_configured
    return if selected_price_id.present? && defined?(Stripe) && ENV['STRIPE_SECRET_KEY'].present?

    flash.now[:alert] = "Le plan tarifaire Stripe n'est pas configuré. Contactez le support."
    @restaurant = Restaurant.new(restaurant_params)
    @admin = Admin.new(admin_params)
    render :new, status: :unprocessable_entity
  end

  def assign_stripe_defaults(restaurant)
    restaurant.stripe_price_id ||= selected_price_id
    restaurant.subscription_status ||= 'pending'

    return true unless stripe_price_lookup_available?

    price = stripe_price
    return true unless price&.respond_to?(:product)

    restaurant.stripe_product_id ||= price.product
    true
  rescue Stripe::StripeError => e
    Rails.logger.error("[Stripe] Unable to fetch price #{selected_price_id}: #{e.message}")
    restaurant.errors.add(:base, "Impossible de vérifier le plan Stripe sélectionné.")
    false
  end

  def selected_price_id
    ENV['STRIPE_PRICE_ID']
  end

  def trial_days
    ENV.fetch('STRIPE_TRIAL_DAYS', 14).to_i
  end

  def stripe_price
    return nil unless stripe_price_lookup_available?

    @stripe_price ||= Stripe::Price.retrieve(selected_price_id)
  end

  def stripe_price_lookup_available?
    selected_price_id.present? && defined?(Stripe) && ENV['STRIPE_SECRET_KEY'].present?
  end

  def create_trial_checkout_session(restaurant, admin)
    Stripe::Checkout::Session.create(
      mode: 'subscription',
      success_url: setup_restaurant_url(restaurant, session_id: '{CHECKOUT_SESSION_ID}'),
      cancel_url: new_restaurant_url,
      customer_email: admin.email,
      line_items: [
        {
          price: selected_price_id,
          quantity: 1
        }
      ],
      subscription_data: {
        trial_period_days: trial_days,
        metadata: {
          restaurant_id: restaurant.id
        }
      },
      metadata: {
        restaurant_id: restaurant.id,
        admin_id: admin.id
      }
    )
  end

  def set_restaurant
    @restaurant = Restaurant.find(params[:id])
  end

  def attach_subscription_if_ready(subscription, session_object)
    return unless session_object.subscription.present?

    stripe_subscription = Stripe::Subscription.retrieve(session_object.subscription)
    subscription.update_from_stripe_subscription(stripe_subscription)
    subscription.update(
      stripe_checkout_session_id: session_object.id,
      stripe_customer_id: session_object.customer
    )
    @restaurant.update(subscription_status: subscription.status)
  rescue Stripe::StripeError => e
    Rails.logger.error("[Stripe] Unable to attach subscription #{session_object.subscription}: #{e.message}")
  end

  def auto_login_pending_admin
    return unless session[:pending_admin_id] && session[:pending_restaurant_id]
    return unless session[:pending_restaurant_id].to_i == @restaurant.id

    admin = Admin.find_by(id: session[:pending_admin_id])
    if admin && admin.restaurant_id == @restaurant.id
      session[:admin_id] = admin.id
      session[:restaurant_id] = admin.restaurant_id
    end

    session.delete(:pending_admin_id)
    session.delete(:pending_restaurant_id)
  end
end
