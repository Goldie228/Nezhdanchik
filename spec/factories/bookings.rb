# == Schema Information
#
# Table name: bookings
#
#  id               :bigint           not null, primary key
#  user_id          :bigint           not null
#  cart_id          :bigint
#  starts_at        :datetime         not null
#  ends_at          :datetime         not null
#  booking_type     :integer          default("individual_seats"), not null
#  require_passport :boolean          default(FALSE)
#  status           :string           default("pending")
#  booking_number   :string           not null
#  total_price      :decimal(8, 2)    default(0.0)
#  special_requests :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  order_id         :bigint
#
FactoryBot.define do
  factory :booking do
    user
    cart { nil }
    order { nil }
    starts_at { Time.zone.now + 1.day }
    ends_at { Time.zone.now + 1.day + 2.hours }
    booking_type { :individual_seats }
    require_passport { false }
    status { 'pending' }
    sequence(:booking_number) { |n| "BK#{Time.current.to_i}#{n}" }
    total_price { 0.0 }

    trait :with_seats do
      after(:create) do |booking|
        table = create(:table)
        seats = create_list(:seat, 2, table: table)
        booking.seats << seats
        booking.save
      end
    end

    trait :whole_table do
      booking_type { :whole_table }
      after(:create) do |booking|
        table = create(:table, seats_count: 4, booking_price: 20.0)
        seats = create_list(:seat, 4, table: table)
        booking.seats << seats
        booking.save
      end
    end

    trait :confirmed do
      status { 'confirmed' }
    end
  end
end
