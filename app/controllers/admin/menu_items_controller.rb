class Admin::MenuItemsController < ApplicationController
  layout 'admin'
  before_action :authenticate_admin!
  before_action :set_menu_item, only: [:show, :edit, :update, :destroy, :toggle_availability]

  def index
    @menu_items = MenuItem.ordered
  end

  def show
  end

  def new
    @menu_item = MenuItem.new
  end

  def create
    @menu_item = MenuItem.new(menu_item_params)

    if @menu_item.save
      redirect_to admin_menu_items_path, notice: 'Plat créé avec succès!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @menu_item.update(menu_item_params)
      redirect_to admin_menu_items_path, notice: 'Plat mis à jour avec succès!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @menu_item.destroy
    redirect_to admin_menu_items_path, notice: 'Plat supprimé avec succès!'
  end

  def toggle_availability
    @menu_item.update(available: !@menu_item.available)

    respond_to do |format|
      format.json { render json: { available: @menu_item.available } }
      format.html { redirect_to admin_menu_items_path }
    end
  end

  private

  def set_menu_item
    @menu_item = MenuItem.find(params[:id])
  end

  def menu_item_params
    params.require(:menu_item).permit(:name, :description, :price, :comment, :available, :position)
  end
end