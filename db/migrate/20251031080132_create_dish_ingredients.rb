class CreateDishIngredients < ActiveRecord::Migration[7.2]
  def change
    create_table :dish_ingredients do |t|
      t.references :dish, null: false, foreign_key: true
      t.references :ingredient, null: false, foreign_key: true
      # Показывает, входит ли ингредиент в состав блюда по умолчанию
      t.boolean :default, default: true
      t.timestamps
    end

    # Уникальный индекс на пару (dish, ingredient) предотвращает дублирование ингредиентов в одном блюде
    add_index :dish_ingredients, [ :dish_id, :ingredient_id ], unique: true
    # Индекс по полю default позволяет быстро получать список стандартных ингредиентов блюда
    add_index :dish_ingredients, :default
  end
end
