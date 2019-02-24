require 'rails_helper'

RSpec.describe Review, type: :model do
  describe 'validations' do
    it { should validate_presence_of :title }
    it { should validate_presence_of :description }
    it { should validate_presence_of :rating }
  end

  describe 'relationships' do
    it { should belong_to :order_item }
    it { should belong_to :user }
  end

  describe 'class methods' do
    it '.my_reviews' do
      user = create(:user)
      user2 = create(:user)
      merchant = create(:merchant)
      item = create(:item, user: merchant)
      order = create(:order, user: user, status: 1)
      order2 = create(:order, user: user, status: 1)
      order3 = create(:order, user: user2, status: 1)
      order_item = create(:fulfilled_order_item, order: order, item: item)
      order_item2 = create(:fulfilled_order_item, order: order2, item: item)
      order_item3 = create(:fulfilled_order_item, order: order3, item: item)
      review = create(:review, user: user, order_item: order_item)
      review2 = create(:review, user: user, order_item: order_item2)
      review3 = create(:review, user: user2, order_item: order_item3)

      expected1 = [review, review2]
      expect(Review.my_reviews(user)).to eq(expected1)

      expected2 = [review3]
      expect(Review.my_reviews(user2)).to eq(expected2)
    end
  end
end
