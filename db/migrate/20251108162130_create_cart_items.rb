class CreateCartItems < ActiveRecord::Migration[7.2]
  def change
    create_table :cart_items do |t|
      # Связь позиции с корзиной пользователя
      t.references :cart, null: false, foreign_key: true, index: true
      # Связь позиции с конкретным блюдом
      t.references :dish, null: false, foreign_key: true, index: true

      # Количество единиц блюда в корзине (целое число)
      t.integer :quantity, null: false, default: 1
      # Флаг "active" позволяет помечать товары удаленными без физического удаления строки (Soft Delete)
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
