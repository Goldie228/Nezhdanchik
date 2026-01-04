# == Schema Information
#
# Table name: tables
#
#  id            :bigint           not null, primary key
#  name          :string           not null
#  seats_count   :integer          not null
#  booking_price :decimal(8, 2)    default(0.0)
#  active        :boolean          default(TRUE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
FactoryBot.define do
  factory :table do
    # sequence гарантирует уникальность имен столов
    sequence(:name) { |n| "Стол #{n}" }
    seats_count { 5 }
    # Цена за бронь стола целиком (если применимо)
    booking_price { 10.00 }
    active { true }
  end
end
