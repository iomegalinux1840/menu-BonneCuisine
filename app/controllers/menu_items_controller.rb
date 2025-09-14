class MenuItemsController < ApplicationController
  def index
    @menu_items = MenuItem.available.ordered.limit(12)
  end
end