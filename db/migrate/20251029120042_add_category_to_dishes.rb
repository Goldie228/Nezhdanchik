class AddCategoryToDishes < ActiveRecord::Migration[7.2]
  def change
    add_reference :dishes, :category, foreign_key: true, index: true
  end
end
