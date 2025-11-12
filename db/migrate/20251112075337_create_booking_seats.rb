class CreateBookingSeats < ActiveRecord::Migration[7.2]
  def change
    create_table :booking_seats do |t|
      # Ссылка на бронирование
      t.references :booking, null: false, foreign_key: true

      # Ссылка на конкретное место
      t.references :seat, null: false, foreign_key: true

      t.timestamps
    end

    # Уникальный индекс: одно место не может быть в одной брони дважды
    add_index :booking_seats, [ :booking_id, :seat_id ], unique: true
  end
end
