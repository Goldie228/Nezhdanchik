class CreateNutrition < ActiveRecord::Migration[7.2]
  def change
    create_table :nutritions do |t|
      t.decimal :proteins, precision: 5, scale: 2
      t.decimal :fats, precision: 5, scale: 2
      t.decimal :carbohydrates, precision: 5, scale: 2

      t.references :nutritable, polymorphic: true, null: false
      t.timestamps
    end
  end
end
