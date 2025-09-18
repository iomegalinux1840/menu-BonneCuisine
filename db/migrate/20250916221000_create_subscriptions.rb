class CreateSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :subscriptions do |t|
      t.references :restaurant, null: false, foreign_key: true
      t.string :email
      t.string :stripe_customer_id
      t.string :stripe_subscription_id
      t.string :stripe_checkout_session_id, null: false
      t.string :price_id
      t.string :status, null: false, default: 'pending'
      t.datetime :current_period_end
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :subscriptions, :stripe_customer_id
    add_index :subscriptions, :stripe_subscription_id
    add_index :subscriptions, :stripe_checkout_session_id, unique: true
    add_index :subscriptions, :status
  end
end
