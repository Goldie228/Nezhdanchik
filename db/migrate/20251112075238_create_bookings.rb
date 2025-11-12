class CreateBookings < ActiveRecord::Migration[7.2]
  def change
    create_table :bookings do |t|
      # Пользователь, который создал бронь
      t.references :user, null: false, foreign_key: true

      # Корзина с товарами, связанная с этой броньью (опционально - бронь может быть без заказа)
      t.references :cart, null: true, foreign_key: true

      # Дата и время начала бронирования
      t.datetime :starts_at, null: false

      # Дата и время окончания бронирования
      t.datetime :ends_at, null: false

      # Тип брони: 0 - отдельные места, 1 - целый столик
      t.integer :booking_type, default: 0, null: false

      # Флаг: требуется ли паспорт для выдачи столика
      t.boolean :require_passport, default: false

      # Статус брони: pending, confirmed, active, completed, cancelled
      t.string :status, default: "pending"

      # Уникальный номер брони для отображения пользователю
      t.string :booking_number, null: false

      # Общая стоимость брони (0 для мест, booking_price столика для брони столика)
      t.decimal :total_price, precision: 8, scale: 2, default: "0.0"

      # Особые пожелания от пользователя
      t.text :special_requests

      t.timestamps
    end

    add_index :bookings, :booking_number, unique: true
    add_index :bookings, :status
    add_index :bookings, :booking_type
    add_index :bookings, :starts_at
    add_index :bookings, :ends_at
  end
end
