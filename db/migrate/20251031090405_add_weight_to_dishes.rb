class AddWeightToDishes < ActiveRecord::Migration[7.2]
  def change
    add_column :dishes, :weight, :integer, default: 100, null: false
  end
end
