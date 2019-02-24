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
    before :each do
      @user = create(:user)
      @user2 = create(:user)
      @merchant = create(:merchant)
      @item = create(:item, user: @merchant)
      @item2 = create(:item, user: @merchant)
      @order = create(:order, user: @user, status: 1)
      @order2 = create(:order, user: @user, status: 1)
      @order3 = create(:order, user: @user2, status: 1)
      @order_item = create(:fulfilled_order_item, order: @order, item: @item)
      @order_item2 = create(:fulfilled_order_item, order: @order2, item: @item)
      @order_item3 = create(:fulfilled_order_item, order: @order3, item: @item)
      @order_item4 = create(:fulfilled_order_item, order: @order3, item: @item2)
      @review = create(:review, user: @user, order_item: @order_item, rating: 1, title: "Review 1")
      @review2 = create(:review, user: @user, order_item: @order_item2, rating: 2, title: "Review 2")
      @review3 = create(:review, user: @user2, order_item: @order_item3, rating: 3, title: "Review 3")
      @review4 = create(:review, user: @user2, order_item: @order_item4, rating: 5, title: "Review 4")
    end

    it '.my_reviews' do
      expected1 = [@review, @review2]
      expect(Review.my_reviews(@user)).to eq(expected1)

      expected2 = [@review3, @review4]
      expect(Review.my_reviews(@user2)).to eq(expected2)
    end

    it ".item_reviews" do
      expected1 = [@review, @review2, @review3]
      expected2 = [@review4]

      expect(Review.item_reviews(@item)).to eq(expected1)
      expect(Review.item_reviews(@item2)).to eq(expected2)
    end

    it ".avg_rating" do
      expect(Review.avg_rating(@item)).to eq(2)
      expect(Review.avg_rating(@item2)).to eq(5)
    end
  end
end
