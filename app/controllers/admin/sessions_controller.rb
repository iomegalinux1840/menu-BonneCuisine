class Admin::SessionsController < ApplicationController
  layout 'admin'
  skip_before_action :verify_authenticity_token, only: [:create]
  before_action :load_restaurant_from_slug
  before_action :redirect_if_logged_in, only: [:new, :create]

  def new
  end

  def create
    admin = Admin.authenticate(params[:email], params[:password])

    if admin && admin.restaurant == @restaurant
      session[:admin_id] = admin.id
      session[:restaurant_id] = @restaurant.id
      redirect_to restaurant_admin_menu_items_path(restaurant_slug: @restaurant.slug), notice: 'Connexion réussie!'
    else
      flash.now[:alert] = 'Email ou mot de passe incorrect'
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:admin_id] = nil
    session[:restaurant_id] = nil
    redirect_to restaurant_menu_path(restaurant_slug: params[:restaurant_slug]), notice: 'Déconnexion réussie!'
  end

  private

  def load_restaurant_from_slug
    @restaurant = Restaurant.active.find_by(slug: params[:restaurant_slug])
    unless @restaurant
      Rails.logger.error "Restaurant not found: #{params[:restaurant_slug]}"
      render file: Rails.public_path.join('404.html'), status: :not_found, layout: false
    end
  end

  def redirect_if_logged_in
    if admin_logged_in? && @restaurant
      redirect_to restaurant_admin_menu_items_path(restaurant_slug: @restaurant.slug)
    end
  end
end