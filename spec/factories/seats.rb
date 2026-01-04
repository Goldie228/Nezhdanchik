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
    # Связь со столом обязательна для корректной топологии ресторана
    table
    # sequence гарантирует уникальность номеров мест в рамках одного стола при последовательном создании
    sequence(:number) { |n| n }
    active { true }
  end
end
