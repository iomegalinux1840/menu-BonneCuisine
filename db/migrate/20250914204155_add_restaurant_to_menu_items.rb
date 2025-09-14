class AddRestaurantToMenuItems < ActiveRecord::Migration[7.1]
  def up
    # First add the column as nullable
    add_reference :menu_items, :restaurant, null: true, foreign_key: true

    # Create a default restaurant for existing data
    default_restaurant = execute(<<-SQL).first
      INSERT INTO restaurants (
        name, slug, subdomain, primary_color, secondary_color,
        font_family, timezone, created_at, updated_at
      ) VALUES (
        'La Bonne Cuisine', 'la-bonne-cuisine', 'labonnecuisine',
        '#8B4513', '#F5DEB3', 'Playfair Display', 'America/Toronto',
        NOW(), NOW()
      ) RETURNING id
    SQL

    # Assign all existing menu items to the default restaurant
    if default_restaurant
      execute("UPDATE menu_items SET restaurant_id = #{default_restaurant['id']} WHERE restaurant_id IS NULL")
    end

    # Now make the column non-nullable
    change_column_null :menu_items, :restaurant_id, false

    # Add index for better query performance
    add_index :menu_items, [:restaurant_id, :position]
    add_index :menu_items, [:restaurant_id, :available]
  end

  def down
    remove_index :menu_items, [:restaurant_id, :available]
    remove_index :menu_items, [:restaurant_id, :position]
    remove_reference :menu_items, :restaurant, foreign_key: true
  end
end
