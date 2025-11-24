# == Schema Information
#
# Table name: orders
#
#  id           :bigint           not null, primary key
#  user_id      :bigint           not null
#  order_number :string           not null
#  total_amount :decimal(10, 2)   not null
#  status       :string           default("pending")
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  booking_id   :bigint
#
FactoryBot.define do
  factory :order do
    user
    sequence(:order_number) { |n| "ORD#{Time.current.to_i}#{n}" }
    total_amount { 0.0 }
    status { 'pending' }

    trait :with_items do
      after(:create) do |order|
        create_list(:order_item, 2, order: order)
      end
    end
  end
end
