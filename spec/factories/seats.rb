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
FactoryBot.define do
  factory :seat do
    table
    sequence(:number) { |n| n }
    active { true }
  end
end
