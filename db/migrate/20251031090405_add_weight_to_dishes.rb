class AddWeightToDishes < ActiveRecord::Migration[7.2]
  def change
    # Добавляет вес блюда в граммах (integer).
    # Значение по умолчанию (100) и null: false обеспечивают корректность расчетов веса заказа/доставки.
    add_column :dishes, :weight, :integer, default: 100, null: false
  end
end
