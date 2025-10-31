class RemovePositionFromCategories < ActiveRecord::Migration[7.2]
  def change
    remove_column :categories, :position, :integer
    remove_index :categories, :position if index_exists?(:categories, :position)
  end
end
