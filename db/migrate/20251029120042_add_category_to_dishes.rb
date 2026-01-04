class AddCategoryToDishes < ActiveRecord::Migration[7.2]
  def change
    # Добавляет связь между блюдами и категориями
    # foreign_key: true гарантирует ссылочную целостность (нельзя удалить категорию с блюдами без каскадного удаления)
    # index: true ускоряет поиск блюд по категории (например, в меню)
    add_reference :dishes, :category, foreign_key: true, index: true
  end
end
