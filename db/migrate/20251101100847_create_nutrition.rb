class CreateNutrition < ActiveRecord::Migration[7.2]
  def change
    create_table :nutritions do |t|
      t.decimal :proteins, precision: 5, scale: 2
      t.decimal :fats, precision: 5, scale: 2
      t.decimal :carbohydrates, precision: 5, scale: 2

      t.timestamps
    end

    add_reference :nutritions, :dish, foreign_key: true
    add_reference :nutritions, :ingredient, foreign_key: true
  end
end
