class Admin::MenuItemsController < ApplicationController
  layout 'admin'
  before_action :authenticate_admin!
  before_action :load_restaurant_from_slug
  before_action :set_menu_item, only: [:show, :edit, :update, :destroy, :toggle_availability]

  # Skip CSRF token verification for file uploads to prevent 422 errors
  skip_before_action :verify_authenticity_token, only: [:create, :update]

  # Ensure Active Storage is available
  before_action :check_active_storage, only: [:create, :update]

  def index
    @menu_items = @restaurant.menu_items.ordered
  end

  def show
  end

  def new
    @menu_item = @restaurant.menu_items.build
  end

  def create
    Rails.logger.info "=== MenuItem CREATE START ==="
    Rails.logger.info "MenuItem create - params keys: #{params.keys}"
    Rails.logger.info "MenuItem create - menu_item params: #{menu_item_params.inspect}"
    Rails.logger.info "MenuItem create - request format: #{request.format}"
    Rails.logger.info "MenuItem create - request method: #{request.method}"
    Rails.logger.info "MenuItem create - content type: #{request.content_type}"

    # Log image information if present
    if menu_item_params[:image].present?
      Rails.logger.info "MenuItem create - image present in params"
      Rails.logger.info "MenuItem create - image temp file: #{menu_item_params[:image].tempfile.path if menu_item_params[:image].respond_to?(:tempfile)}"
      Rails.logger.info "MenuItem create - image original filename: #{menu_item_params[:image].original_filename if menu_item_params[:image].respond_to?(:original_filename)}"
      Rails.logger.info "MenuItem create - image content type: #{menu_item_params[:image].content_type if menu_item_params[:image].respond_to?(:content_type)}"
      Rails.logger.info "MenuItem create - image size: #{menu_item_params[:image].size if menu_item_params[:image].respond_to?(:size)}"
    else
      Rails.logger.info "MenuItem create - no image in params"
    end

    begin
      Rails.logger.info "About to build menu_item with params"
      @menu_item = @restaurant.menu_items.build(menu_item_params)
      Rails.logger.info "MenuItem built: #{@menu_item.inspect}"

      save_result = @menu_item.save
      Rails.logger.info "Save result: #{save_result}"

      if save_result
        Rails.logger.info "MenuItem created successfully: #{@menu_item.name}"
        Rails.logger.info "MenuItem has image attached: #{@menu_item.image.attached?}"

        if @menu_item.image.attached?
          Rails.logger.info "Created image details: filename=#{@menu_item.image.filename}, size=#{@menu_item.image.byte_size}, content_type=#{@menu_item.image.content_type}"
        end

        Rails.logger.info "=== MenuItem CREATE SUCCESS ==="
        redirect_to restaurant_admin_menu_items_path(restaurant_slug: @restaurant.slug), notice: 'Plat créé avec succès!'
      else
        Rails.logger.error "MenuItem creation failed: #{@menu_item.errors.full_messages.join(', ')}"
        Rails.logger.error "MenuItem validation errors: #{@menu_item.errors.inspect}"
        Rails.logger.error "MenuItem state after failed save: attached?=#{@menu_item.image.attached?}"
        Rails.logger.error "=== MenuItem CREATE FAILED ==="
        render :new, status: :unprocessable_entity
      end
    rescue => e
      Rails.logger.error "MenuItem create exception: #{e.class.name} - #{e.message}"
      Rails.logger.error "MenuItem create backtrace: #{e.backtrace.first(10).join("\n")}"
      Rails.logger.error "=== MenuItem CREATE EXCEPTION ==="
      @menu_item = @restaurant.menu_items.build(menu_item_params) # Rebuild for form display
      @menu_item.errors.add(:base, "Une erreur inattendue s'est produite lors de la création: #{e.message}")
      render :new, status: :internal_server_error
    end
  end

  def edit
  end

  def update
    Rails.logger.info "=== MenuItem UPDATE START ==="
    Rails.logger.info "MenuItem update - params keys: #{params.keys}"
    Rails.logger.info "MenuItem update - menu_item params: #{menu_item_params.inspect}"
    Rails.logger.info "MenuItem update - authenticity_token present: #{params[:authenticity_token].present?}"
    Rails.logger.info "MenuItem update - request format: #{request.format}"
    Rails.logger.info "MenuItem update - request method: #{request.method}"
    Rails.logger.info "MenuItem update - content type: #{request.content_type}"

    # Log image information if present
    if menu_item_params[:image].present?
      Rails.logger.info "MenuItem update - image present in params"
      Rails.logger.info "MenuItem update - image temp file: #{menu_item_params[:image].tempfile.path if menu_item_params[:image].respond_to?(:tempfile)}"
      Rails.logger.info "MenuItem update - image original filename: #{menu_item_params[:image].original_filename if menu_item_params[:image].respond_to?(:original_filename)}"
      Rails.logger.info "MenuItem update - image content type: #{menu_item_params[:image].content_type if menu_item_params[:image].respond_to?(:content_type)}"
      Rails.logger.info "MenuItem update - image size: #{menu_item_params[:image].size if menu_item_params[:image].respond_to?(:size)}"
    else
      Rails.logger.info "MenuItem update - no image in params"
    end

    begin
      Rails.logger.info "About to call @menu_item.update with params"
      update_result = @menu_item.update(menu_item_params)
      Rails.logger.info "Update result: #{update_result}"

      if update_result
        Rails.logger.info "MenuItem updated successfully: #{@menu_item.name}"
        Rails.logger.info "MenuItem has image attached: #{@menu_item.image.attached?}"

        if @menu_item.image.attached?
          Rails.logger.info "Image details: filename=#{@menu_item.image.filename}, size=#{@menu_item.image.byte_size}, content_type=#{@menu_item.image.content_type}"
        end

        Rails.logger.info "=== MenuItem UPDATE SUCCESS ==="
        redirect_to restaurant_admin_menu_items_path(restaurant_slug: @restaurant.slug), notice: 'Plat mis à jour avec succès!'
      else
        Rails.logger.error "MenuItem update failed: #{@menu_item.errors.full_messages.join(', ')}"
        Rails.logger.error "MenuItem validation errors: #{@menu_item.errors.inspect}"
        Rails.logger.error "MenuItem state after failed update: attached?=#{@menu_item.image.attached?}"
        Rails.logger.error "=== MenuItem UPDATE FAILED ==="
        render :edit, status: :unprocessable_entity
      end
    rescue => e
      Rails.logger.error "MenuItem update exception: #{e.class.name} - #{e.message}"
      Rails.logger.error "MenuItem update backtrace: #{e.backtrace.first(10).join("\n")}"
      Rails.logger.error "=== MenuItem UPDATE EXCEPTION ==="
      @menu_item.errors.add(:base, "Une erreur inattendue s'est produite lors de la mise à jour: #{e.message}")
      render :edit, status: :internal_server_error
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

  private

  def check_active_storage
    Rails.logger.info "Checking Active Storage availability..."
    Rails.logger.info "ActiveStorage defined: #{defined?(ActiveStorage)}"
    Rails.logger.info "ActiveStorage::Blob defined: #{defined?(ActiveStorage::Blob)}"
    Rails.logger.info "ActiveStorage::Attachment defined: #{defined?(ActiveStorage::Attachment)}"

    # Test if we can create a basic Active Storage object
    begin
      blob = ActiveStorage::Blob.new
      Rails.logger.info "Active Storage blob creation successful"
    rescue => e
      Rails.logger.error "Active Storage blob creation failed: #{e.message}"
    end
  end
end