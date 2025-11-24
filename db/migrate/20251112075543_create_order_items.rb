class CreateOrderItems < ActiveRecord::Migration[7.2]
  def change
    create_table :order_items do |t|
      # Заказ, к которому относится эта позиция
      t.references :order, null: false, foreign_key: true

      # Блюдо из меню
      t.references :dish, null: false, foreign_key: true

      # Количество порций
      t.integer :quantity, null: false

      # Цена за единицу на момент заказа (фиксируем, т.к. цена блюда может меняться)
      t.decimal :unit_price, precision: 8, scale: 2, null: false

      # Общая стоимость позиции (quantity * unit_price)
      t.decimal :total_price, precision: 8, scale: 2, null: false

      # Особые пожелания по приготовлению (без лука, острое и т.д.)
      t.text :special_instructions

      t.timestamps
    end
  end
end
