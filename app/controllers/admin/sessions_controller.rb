class Admin::SessionsController < ApplicationController
  include CurrentTenant
  layout 'admin'
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
    @restaurant = Restaurant.find_by!(slug: params[:restaurant_slug])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Restaurant not found'
  end

  def redirect_if_logged_in
    if admin_logged_in? && @restaurant
      redirect_to restaurant_admin_menu_items_path(restaurant_slug: @restaurant.slug)
    end
  end
end