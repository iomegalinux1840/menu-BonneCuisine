class AddMenuDisplayStyleToRestaurants < ActiveRecord::Migration[7.1]
  def change
    add_column :restaurants, :menu_display_style, :string, null: false, default: 'showcase'
    add_index :restaurants, :menu_display_style
  end
end
