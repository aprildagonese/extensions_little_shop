require 'rails_helper'
include ActionView::Helpers::NumberHelper

RSpec.describe 'items show workflow', type: :feature do
  it 'shows basic information about each item' do
    user = create(:user)
    merchant = create(:merchant)
    item = create(:item, user: merchant)
    order_1 = create(:completed_order, user: user)
    create(:fulfilled_order_item, order: order_1, item: item, quantity: 5, price: 2, created_at: 3.days.ago, updated_at: 1.day.ago)
    order_2 = create(:completed_order, user: user)
    create(:fulfilled_order_item, order: order_2, item: item, quantity: 5, price: 2, created_at: 1.days.ago, updated_at: 1.hour.ago)

    visit item_path(item)

    expect(page).to have_content(item.name)
    expect(page).to have_content(item.description)
    expect(page.find("#item-#{item.id}-image")['src']).to have_content(item.image)
    expect(page).to have_content("Sold by: #{item.user.name}")
    expect(page).to have_content("In stock: #{item.inventory}")
    expect(page).to have_content(number_to_currency(item.price))
    expect(page).to have_content("Average time to fulfill: 1 day 11 hours 30 minutes")
  end
  it 'shows alternate data if out of stock or never fulfilled' do
    user = create(:user)
    merchant = create(:merchant)
    item = create(:item, user: merchant, inventory: 0)

    visit item_path(item)

    expect(page).to have_content("Out of Stock")
    expect(page).to_not have_content("In stock: #{item.inventory}")
    expect(page).to have_content("Average time to fulfill: n/a")
  end
  it 'shows all review data for that item' do
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

    visit item_path(@item)

    within ".review-#{@review.id}" do
      expect(page).to have_content("#{@review.title}")
      expect(page).to have_content("#{@review.description}")
      expect(page).to have_content("Rating: #{@review.rating}")
      expect(page).to have_content("Review Date: #{@review.created_at.to_date.to_s}")
      expect(page).to_not have_content("Updated On")
    end
    within ".review-#{@review2.id}" do
      expect(page).to have_content("#{@review2.title}")
      expect(page).to have_content("#{@review2.description}")
      expect(page).to have_content("Rating: #{@review2.rating}")
      expect(page).to have_content("Review Date: #{@review2.created_at.to_date.to_s}")
      expect(page).to_not have_content("Updated On")
    end
    within ".review-#{@review3.id}" do
      expect(page).to have_content("#{@review3.title}")
      expect(page).to have_content("#{@review3.description}")
      expect(page).to have_content("Rating: #{@review3.rating}")
      expect(page).to have_content("Review Date: #{@review3.created_at.to_date.to_s}")
      expect(page).to_not have_content("Updated On")
    end
    expect(page).to_not have_content("#{@review4.title}")
  end
end
