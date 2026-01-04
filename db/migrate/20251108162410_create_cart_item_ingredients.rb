class CreateCartItemIngredients < ActiveRecord::Migration[7.2]
  def change
    create_table :cart_item_ingredients do |t|
      # Связывает кастомизацию с конкретной позицией в корзине
      t.references :cart_item, null: false, foreign_key: true, index: true
      # Указывает, какой ингредиент был изменен (добавлен или убран)
      t.references :ingredient, null: false, foreign_key: true, index: true

      # Определяет, находится ли ингредиент в составе (true) или убран клиентом (false)
      t.boolean :included, null: false, default: true
      # Фиксирует, был ли ингредиент частью оригинального рецепта блюда
      # (нужно для расчета цены: добавленные ингредиенты увеличивают стоимость, убранные — уменьшают)
      t.boolean :default_in_dish, null: false, default: true

      # Цена ингредиента в момент добавления в корзину (хранится в копейках/центах как integer).
      # Фиксация цены важна, чтобы изменение цены в справочнике не меняло стоимость уже оформленных заказов.
      t.integer :price, null: false, default: 0

      t.timestamps
    end

    # Составной уникальный индекс предотвращает дублирование одного ингредиента в одной позиции корзины
    add_index :cart_item_ingredients, [ :cart_item_id, :ingredient_id ], unique: true
  end
end
