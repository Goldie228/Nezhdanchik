# == Schema Information
#
# Table name: carts
#
#  id         :bigint           not null, primary key
#  user_id    :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  booking_id :bigint
#
FactoryBot.define do
  factory :cart do
    association :user
  end
end
