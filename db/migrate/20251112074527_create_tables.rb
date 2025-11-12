class CreateTables < ActiveRecord::Migration[7.2]
  def change
    create_table :tables do |t|
      # Название столика (например "Стол 1")
      t.string :name, null: false

      # Количество мест за этим столиком
      t.integer :seats_count, null: false

      # Цена бронирования всего столика
      t.decimal :booking_price, precision: 8, scale: 2, default: "0.0"

      # Активен ли столик для бронирования
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :tables, :active
  end
end
