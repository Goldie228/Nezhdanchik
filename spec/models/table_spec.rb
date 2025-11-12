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
# spec/models/table_spec.rb
require 'rails_helper'

RSpec.describe Table, type: :model do
  let(:table) { create(:table) }

  describe '#available_seats_count' do
    let(:user) { create(:user) }
    let(:table) { create(:table, seats_count: 4) }
    let!(:seats) { create_list(:seat, 4, table: table) }

    it 'returns all seats when no bookings' do
      expect(table.available_seats_count(Time.current + 1.day, Time.current + 1.day + 2.hours)).to eq(4)
    end

    it 'returns available seats excluding booked ones' do
      # Создаем отдельный стол и места для первого бронирования
      other_table = create(:table)
      other_seats = create_list(:seat, 2, table: other_table)

      # Создаем первое бронирование с другими местами
      booking1 = Booking.create!(
        user: user,
        starts_at: Time.current + 1.day,
        ends_at: Time.current + 1.day + 2.hours,
        status: 'confirmed',
        booking_number: "BK#{Time.current.to_i}001"
      )
      booking1.seats << other_seats

      # Проверяем, что все места нашего стола свободны
      expect(table.available_seats_count(Time.current + 1.day, Time.current + 1.day + 2.hours)).to eq(4)

      # Создаем второе бронирование с местами нашего стола
      booking2 = Booking.create!(
        user: user,
        starts_at: Time.current + 1.day,
        ends_at: Time.current + 1.day + 2.hours,
        status: 'confirmed',
        booking_number: "BK#{Time.current.to_i}002"
      )
      booking2.seats << seats.first(2)

      # Проверяем, что осталось 2 свободных места
      expect(table.available_seats_count(Time.current + 1.day, Time.current + 1.day + 2.hours)).to eq(2)
    end
  end
end
