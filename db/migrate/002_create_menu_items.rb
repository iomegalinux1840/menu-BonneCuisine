class CreateMenuItems < ActiveRecord::Migration[7.0]
  def change
    create_table :menu_items do |t|
      t.string :name, null: false
      t.text :description
      t.decimal :price, precision: 8, scale: 2, null: false
      t.text :comment
      t.boolean :available, default: true, null: false
      t.integer :position, null: false

      t.timestamps
    end

    add_index :menu_items, :position
    add_index :menu_items, :available
  end
end