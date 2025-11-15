class AddMenuStyleFieldsToRestaurants < ActiveRecord::Migration[7.1]
  def change
    add_column :restaurants, :menu_font_size, :string, default: 'medium', null: false
    add_column :restaurants, :menu_font_color, :string, default: '#f8fafc', null: false
    add_column :restaurants, :menu_background_color, :string, default: '#0f172a', null: false
    add_column :restaurants, :menu_accent_color, :string, default: '#facc15', null: false
  end
end
