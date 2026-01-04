class CreateIngredients < ActiveRecord::Migration[7.2]
  def change
    create_table :ingredients do |t|
      t.string  :name, null: false
      # precision: 8, scale: 2 позволяет хранить значения до 999,999.99 (достаточно для цены ингредиента)
      t.decimal :price, precision: 8, scale: 2, default: 0.0
      t.boolean :available, default: true # Флаг доступности для заказов
      t.boolean :allergen, default: false # Помогает выделять аллергены для клиентов
      t.timestamps
    end

    # Уникальный индекс по имени гарантирует отсутствие дубликатов ингредиентов
    add_index :ingredients, :name, unique: true
    # Индекс по available ускоряет фильтрацию доступных ингредиентов в интерфейсе
    add_index :ingredients, :available
  end
end
