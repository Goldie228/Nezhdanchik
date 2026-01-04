# == Schema Information
#
# Table name: booking_seats
#
#  id         :bigint           not null, primary key
#  booking_id :bigint           not null
#  seat_id    :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :booking_seat do
    # Явное указание ассоциаций гарантирует создание связанных записей в БД
    # Это предотвращает ошибки "Foreign Key Violation" при тестировании
    association :booking
    association :seat
  end
end
