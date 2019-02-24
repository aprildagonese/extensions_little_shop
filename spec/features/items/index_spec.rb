require 'rails_helper'
include ActionView::Helpers::NumberHelper

RSpec.describe 'items index workflow', type: :feature do
  describe 'shows all active items to visitors' do
    it 'displays basic item data' do
      items = create_list(:item, 3)
      inactive_items = create_list(:inactive_item, 2)

      visit items_path

      items.each do |item|
        within "#item-#{item.id}" do
          expect(page).to have_link(item.name)
          expect(page).to have_content("Sold by: #{item.user.name}")
          expect(page).to have_content("In stock: #{item.inventory}")
          expect(page).to have_content(number_to_currency(item.price))
          expect(page.find("#item-#{item.id}-image")['src']).to have_content(item.image)
        end
      end
      inactive_items.each do |item|
        expect(page).to_not have_css("#item-#{item.id}")
        expect(page).to_not have_content(item.name)
      end
    end

    it "displays average review for each item" do
      item1 = create(:item)
      user = create(:user)
      order1 = create(:order, status: 1, user: user)
      order2 = create(:order, status: 1, user: user)
      order3 = create(:order, status: 1, user: user)
      oi1 = create(:fulfilled_order_item, order: order1, item: item1)
      oi2 = create(:fulfilled_order_item, order: order2, item: item1)
      oi3 = create(:fulfilled_order_item, order: order3, item: item1)
      review1 = create(:review, user: user, order_item: oi1, rating: 5)
      review2 = create(:review, user: user, order_item: oi2, rating: 3)
      review3 = create(:review, user: user, order_item: oi3, rating: 1)

      visit items_path

      within "#item-#{item1.id}" do
        expect(page).to have_content("Average Rating: 3")
      end
    end
  end
end
