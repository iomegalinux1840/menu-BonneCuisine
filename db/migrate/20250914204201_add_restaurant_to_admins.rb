class AddRestaurantToAdmins < ActiveRecord::Migration[7.1]
  def up
    # First add the columns
    add_reference :admins, :restaurant, null: true, foreign_key: true
    add_column :admins, :role, :string, default: 'manager'
    add_column :admins, :last_login_at, :datetime

    # Get the default restaurant ID (created in the previous migration)
    default_restaurant = execute("SELECT id FROM restaurants WHERE slug = 'la-bonne-cuisine' LIMIT 1").first

    # Assign all existing admins to the default restaurant as owners
    if default_restaurant
      execute("UPDATE admins SET restaurant_id = #{default_restaurant['id']}, role = 'owner' WHERE restaurant_id IS NULL")
    end

    # Now make the restaurant_id non-nullable
    change_column_null :admins, :restaurant_id, false

    # Add indexes for better performance
    add_index :admins, [:restaurant_id, :email], unique: true
    # The restaurant_id index is already created by add_reference
  end

  def down
    remove_index :admins, [:restaurant_id, :email]
    # remove_index :admins, :restaurant_id is handled by remove_reference
    remove_column :admins, :last_login_at
    remove_column :admins, :role
    remove_reference :admins, :restaurant, foreign_key: true
  end
end
