class AddBookingOrderReferences < ActiveRecord::Migration[7.2]
  def change
    # Добавляем booking_id в orders - автоматически создаст индекс
    add_reference :orders, :booking, null: true, foreign_key: true

    # Добавляем order_id в bookings - автоматически создаст индекс
    add_reference :bookings, :order, null: true, foreign_key: true
  end
end
