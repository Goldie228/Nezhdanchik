class CreateCartItems < ActiveRecord::Migration[7.2]
  def change
    create_table :cart_items do |t|
      t.references :cart, null: false, foreign_key: true, index: true
      t.references :dish, null: false, foreign_key: true, index: true

      t.integer :quantity, null: false, default: 1
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
