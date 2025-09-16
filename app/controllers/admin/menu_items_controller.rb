class Admin::MenuItemsController < ApplicationController
  layout 'admin'
  before_action :authenticate_admin!
  before_action :load_restaurant_from_slug
  before_action :set_menu_item, only: [:show, :edit, :update, :destroy, :toggle_availability]

  # Skip CSRF token verification for file uploads to prevent 422 errors
  skip_before_action :verify_authenticity_token, only: [:create, :update]

  def index
    @menu_items = @restaurant.menu_items.ordered
  end

  def show
  end

  def new
    @menu_item = @restaurant.menu_items.build
  end

  def create
    Rails.logger.info "MenuItem create - params keys: #{params.keys}"
    Rails.logger.info "MenuItem create - menu_item params: #{menu_item_params.inspect}"

    @menu_item = @restaurant.menu_items.build(menu_item_params)

    if @menu_item.save
      Rails.logger.info "MenuItem created successfully: #{@menu_item.name}"
      redirect_to restaurant_admin_menu_items_path(restaurant_slug: @restaurant.slug), notice: 'Plat créé avec succès!'
    else
      Rails.logger.error "MenuItem creation failed: #{@menu_item.errors.full_messages.join(', ')}"
      Rails.logger.error "MenuItem validation errors: #{@menu_item.errors.inspect}"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    Rails.logger.info "MenuItem update - params keys: #{params.keys}"
    Rails.logger.info "MenuItem update - menu_item params: #{menu_item_params.inspect}"
    Rails.logger.info "MenuItem update - authenticity_token present: #{params[:authenticity_token].present?}"

    if @menu_item.update(menu_item_params)
      Rails.logger.info "MenuItem updated successfully: #{@menu_item.name}"
      redirect_to restaurant_admin_menu_items_path(restaurant_slug: @restaurant.slug), notice: 'Plat mis à jour avec succès!'
    else
      Rails.logger.error "MenuItem update failed: #{@menu_item.errors.full_messages.join(', ')}"
      Rails.logger.error "MenuItem validation errors: #{@menu_item.errors.inspect}"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @menu_item.destroy
    redirect_to restaurant_admin_menu_items_path(restaurant_slug: @restaurant.slug), notice: 'Plat supprimé avec succès!'
  end

  def toggle_availability
    @menu_item.update(available: !@menu_item.available)

    respond_to do |format|
      format.json { render json: { available: @menu_item.available } }
      format.html { redirect_to restaurant_admin_menu_items_path(restaurant_slug: @restaurant.slug) }
    end
  end

  private

  def load_restaurant_from_slug
    @restaurant = Restaurant.active.find_by(slug: params[:restaurant_slug])
    unless @restaurant
      Rails.logger.error "Restaurant not found for menu items: #{params[:restaurant_slug]}"
      respond_to do |format|
        format.html { render plain: "404 Restaurant Not Found", status: :not_found }
        format.json { render json: { error: "Restaurant not found" }, status: :not_found }
      end
      return
    end

    # Ensure admin belongs to this restaurant
    if current_admin && current_admin.restaurant_id != @restaurant.id
      redirect_to root_path, alert: 'Access denied'
    end
  end

  def set_menu_item
    @menu_item = @restaurant.menu_items.find(params[:id])
  end

  def menu_item_params
    params.require(:menu_item).permit(:name, :description, :price, :comment, :available, :position, :image)
  end
end