class Review < ApplicationRecord
  belongs_to :order_item
  belongs_to :user
  has_one :item, through: :order_item
  has_one :order, through: :order_item

  validates_presence_of :title, :description, :user_id, :order_item_id
  validates :rating, presence: true, numericality: {
    only_integer: false,
    greater_than_or_equal_to: 1,
    less_than_or_equal_to: 5
  }

  def self.my_reviews(user)
    self.where(user_id: user.id)
  end

  def self.item_reviews(item)
    item.reviews
  end

  def self.avg_rating(item)
    item.reviews.average(:rating).to_f.round(2)
  end
end
