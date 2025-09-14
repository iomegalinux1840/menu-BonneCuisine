class CreateRestaurants < ActiveRecord::Migration[7.1]
  def change
    create_table :restaurants do |t|
      t.string :name
      t.string :slug
      t.string :subdomain
      t.string :custom_domain
      t.string :logo_url
      t.string :primary_color
      t.string :secondary_color
      t.string :font_family
      t.string :timezone
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :restaurants, :slug, unique: true
    add_index :restaurants, :subdomain, unique: true
    add_index :restaurants, :custom_domain, unique: true
  end
end
