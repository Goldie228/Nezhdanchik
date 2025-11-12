class AddBookingToCarts < ActiveRecord::Migration[7.2]
  def change
    # Добавляем ссылку на бронь в корзину (опционально)
    add_reference :carts, :booking, null: true, foreign_key: true
  end
end
