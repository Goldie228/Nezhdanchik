class CreateIngredients < ActiveRecord::Migration[7.2]
  def change
    create_table :ingredients do |t|
      t.string  :name, null: false
      t.decimal :price, precision: 8, scale: 2, default: 0.0
      t.boolean :available, default: true
      t.boolean :allergen, default: false
      t.timestamps
    end

    add_index :ingredients, :name, unique: true
    add_index :ingredients, :available
  end
end
