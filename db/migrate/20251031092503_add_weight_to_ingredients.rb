class AddWeightToIngredients < ActiveRecord::Migration[7.2]
  def change
    # Добавляет вес ингредиента в граммах (integer) для корректного расчета калорийности и итогового веса блюда
    # Значение по умолчанию (10) и null: false обеспечивают целостность данных
    add_column :ingredients, :weight, :integer, default: 10, null: false
  end
end
