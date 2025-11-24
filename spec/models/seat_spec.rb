# == Schema Information
#
# Table name: seats
#
#  id         :bigint           not null, primary key
#  table_id   :bigint           not null
#  number     :integer          not null
#  active     :boolean          default(TRUE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe Seat, type: :model do
  describe 'validations' do
    let(:table) { create(:table) }

    it 'validates uniqueness of number scoped to table_id' do
      create(:seat, table: table, number: 1)
      duplicate_seat = build(:seat, table: table, number: 1)
      expect(duplicate_seat).not_to be_valid
      expect(duplicate_seat.errors[:number]).to include('уже существует для этого столика')
    end
  end
end
