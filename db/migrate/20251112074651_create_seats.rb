class CreateSeats < ActiveRecord::Migration[7.2]
  def change
    create_table :seats do |t|
      t.references :table, null: false, foreign_key: true

      # Номер места
      t.integer :number, null: false

      # Активно ли место для бронирования
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :seats, [ :number ], unique: true
  end
end
