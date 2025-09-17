class AddLayoutSettingsToRestaurants < ActiveRecord::Migration[7.1]
  def change
    add_column :restaurants, :menu_image_size, :string, null: false, default: 'small'
    add_column :restaurants, :menu_grid_columns, :integer, null: false, default: 3
    add_column :restaurants, :message_of_the_day, :text
  end
end
