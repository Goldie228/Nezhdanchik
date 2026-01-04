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
require 'rails_helper'

RSpec.describe BookingSeat, type: :model do
  describe 'validations' do
    let(:booking) { create(:booking) }
    let(:seat) { create(:seat) }

    # Создаем существующую связь для имитации занятости места
    let!(:existing_booking_seat) { create(:booking_seat, booking: booking, seat: seat) }

    # Проверяет уникальность пары бронь+место.
    # Использование build (без сохранения) корректно, так как уникальность проверяется на уровне БД и валидаций.
    it 'validates uniqueness of booking_id scoped to seat_id' do
      new_booking_seat = build(:booking_seat, booking: booking, seat: seat)
      expect(new_booking_seat).not_to be_valid
      expect(new_booking_seat.errors[:booking_id]).to be_present
    end
  end

  describe 'associations' do
    # shoulda-matchers автоматически проверят наличие внешних ключей и методов .booking и .seat
    it { should belong_to(:booking) }
    it { should belong_to(:seat) }
  end
end
