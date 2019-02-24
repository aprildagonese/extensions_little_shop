FactoryBot.define do
  factory :review do
    association :order_item, factory: :fulfilled_order_item
    association :user, factory: :user
    sequence(:title) { |n| "Review Title #{n}" }
    sequence(:description) { |n| "#{n} A bunch of review words" }
    sequence(:rating) { rand(1..5) }
  end
end
