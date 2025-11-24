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
require 'rails_helper'

RSpec.describe Booking, type: :model do
  let(:user) { create(:user) }
  let(:booking) { create(:booking, user: user) }

  describe 'validations' do
    it { should validate_presence_of(:starts_at) }
    it { should validate_presence_of(:ends_at) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:cart).optional }
    it { should belong_to(:order).optional }
    it { should have_many(:booking_seats).dependent(:destroy) }
    it { should have_many(:seats).through(:booking_seats) }
  end

  describe 'enums' do
    it { should define_enum_for(:booking_type).with_values(individual_seats: 0, whole_table: 1) }
  end

  describe 'callbacks' do
    describe '#calculate_total_price' do
      context 'when booking whole table' do
        it 'sets total_price to table booking price' do
          booking = create(:booking, :whole_table)
          booking.reload
          expect(booking.total_price).to eq(20.0)
        end
      end
    end
  end

  describe 'scopes' do
    describe '.future' do
      let!(:future_booking) do
        table1 = create(:table)
        seats1 = create_list(:seat, 2, table: table1)
        create(:booking,
               user: user,
               seats: seats1,
               starts_at: Time.current + 2.days,
               ends_at: Time.current + 2.days + 2.hours)
      end

      let!(:past_booking) do
        table2 = create(:table)
        seats2 = create_list(:seat, 2, table: table2)
        create(:booking,
               user: user,
               seats: seats2,
               starts_at: Time.current - 2.days,
               ends_at: Time.current - 2.days + 2.hours)
      end

      it 'returns only future bookings' do
        future_bookings = Booking.future
        expect(future_bookings).to include(future_booking)
        expect(future_bookings).not_to include(past_booking)
      end
    end

    describe '.active' do
      let!(:active_booking) do
        table1 = create(:table)
        seats1 = create_list(:seat, 2, table: table1)
        create(:booking,
               user: user,
               seats: seats1,
               starts_at: Time.current - 1.hour,
               ends_at: Time.current + 1.hour)
      end

      let!(:future_booking) do
        table2 = create(:table)
        seats2 = create_list(:seat, 2, table: table2)
        create(:booking,
               user: user,
               seats: seats2,
               starts_at: Time.current + 3.hours,
               ends_at: Time.current + 5.hours)
      end

      let!(:past_booking) do
        table3 = create(:table)
        seats3 = create_list(:seat, 2, table: table3)
        create(:booking,
               user: user,
               seats: seats3,
               starts_at: Time.current - 3.hours,
               ends_at: Time.current - 1.hour)
      end

      it 'returns only active bookings' do
        active_bookings = Booking.active
        expect(active_bookings).to include(active_booking)
        expect(active_bookings).not_to include(future_booking)
        expect(active_bookings).not_to include(past_booking)
      end
    end
  end

  describe '#duration_hours' do
    it 'calculates duration in hours' do
      booking.starts_at = Time.current
      booking.ends_at = Time.current + 3.hours
      expect(booking.duration_hours).to eq(3)
    end
  end

  describe '#table' do
    it 'returns table from first seat' do
      table = create(:table)
      seat = create(:seat, table: table)
      booking.seats << seat
      expect(booking.table).to eq(table)
    end
  end

  describe 'overlapping bookings validation' do
    let(:seat) { create(:seat) }
    let!(:existing_booking) do
      create(:booking, :confirmed, starts_at: Time.current + 1.day, ends_at: Time.current + 1.day + 2.hours)
    end

    before { existing_booking.seats << seat }

    it 'does not allow overlapping bookings for the same seat' do
      overlapping_booking = build(:booking, starts_at: Time.current + 1.day + 1.hour, ends_at: Time.current + 1.day + 3.hours)
      overlapping_booking.seats << seat

      expect(overlapping_booking).not_to be_valid
      expect(overlapping_booking.errors[:base]).to include('Некоторые места уже забронированы на это время')
    end
  end

  describe 'user association' do
    it 'belongs to a user with correct attributes' do
      expect(booking.user).to eq(user)
      expect(booking.user.email).to eq('user@example.com')
      expect(booking.user.first_name).to eq('John')
      expect(booking.user.last_name).to eq('Doe')
    end

    it 'destroys bookings when user is destroyed' do
      booking_id = booking.id
      user.destroy
      expect(Booking.find_by(id: booking_id)).to be_nil
    end
  end
end
