class AddWeightToIngredients < ActiveRecord::Migration[7.2]
  def change
    add_column :ingredients, :weight, :integer, default: 10, null: false
  end
end
