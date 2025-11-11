class CreateCartItemIngredients < ActiveRecord::Migration[7.2]
  def change
    create_table :cart_item_ingredients do |t|
      t.references :cart_item, null: false, foreign_key: true, index: true
      t.references :ingredient, null: false, foreign_key: true, index: true

      t.boolean :included, null: false, default: true
      t.boolean :default_in_dish, null: false, default: true

      t.integer :price, null: false, default: 0

      t.timestamps
    end

    add_index :cart_item_ingredients, [ :cart_item_id, :ingredient_id ], unique: true
  end
end
