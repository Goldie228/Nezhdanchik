class CreateOrders < ActiveRecord::Migration[7.2]
  def change
    create_table :orders do |t|
      # Пользователь, сделавший заказ
      t.references :user, null: false, foreign_key: true

      # Уникальный номер заказа для отображения пользователю
      t.string :order_number, null: false

      # Общая сумма заказа (сумма всех order_items)
      t.decimal :total_amount, precision: 10, scale: 2, null: false

      # Статус заказа: pending, paid, preparing, ready, completed, cancelled
      t.string :status, default: "pending"

      t.timestamps
    end

    add_index :orders, :order_number, unique: true
  end
end
