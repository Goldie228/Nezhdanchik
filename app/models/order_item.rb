# == Schema Information
#
# Table name: order_items
#
#  id                   :bigint           not null, primary key
#  order_id             :bigint           not null
#  dish_id              :bigint           not null
#  quantity             :integer          not null
#  unit_price           :decimal(8, 2)    not null
#  total_price          :decimal(8, 2)    not null
#  special_instructions :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
class OrderItem < ApplicationRecord
  # Связь с заказом, в который входит эта позиция
  belongs_to :order
  # Связь с блюдом. Важно: цена блюда может измениться в будущем, поэтому мы фиксируем unit_price в момент заказа.
  belongs_to :dish

  # Колбэк гарантирует, что итоговая цена всегда актуальна перед записью в БД
  before_save :calculate_total_price

  # Расчет полной стоимости позиции товара.
  # Хранение total_price в БД (денормализация) позволяет быстро считать сумму заказа через SQL SUM,
  # не выполняя вычисления для каждой строки при рендеринге чека.
  def calculate_total_price
    self.total_price = quantity * unit_price
  end
end
