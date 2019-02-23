class Review < ApplicationRecord
  belongs_to :order_item
  belongs_to :user

  validates_presence_of :title, :description, :user_id, :order_item_id
  validates :rating, presence: true, numericality: {
    only_integer: false,
    greater_than_or_equal_to: 1,
    less_than_or_equal_to: 5
  }
end
