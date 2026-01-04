class CreateNutrition < ActiveRecord::Migration[7.2]
  def change
    create_table :nutritions do |t|
      # precision: 5, scale: 2 позволяет хранить значения до 999.99 грамм
      t.decimal :proteins, precision: 5, scale: 2
      t.decimal :fats, precision: 5, scale: 2
      t.decimal :carbohydrates, precision: 5, scale: 2

      t.timestamps
    end

    # Связь с блюдом для указания КБЖУ готового продукта
    add_reference :nutritions, :dish, foreign_key: true
    # Связь с ингредиентом для указания КБЖУ отдельной компоненты
    add_reference :nutritions, :ingredient, foreign_key: true
  end
end
