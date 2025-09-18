class AddStripeFieldsToRestaurants < ActiveRecord::Migration[7.1]
  def change
    add_column :restaurants, :stripe_price_id, :string
    add_column :restaurants, :stripe_product_id, :string
    add_column :restaurants, :subscription_status, :string

    add_index :restaurants, :stripe_price_id
  end
end
