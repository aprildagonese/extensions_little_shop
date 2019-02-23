require 'rails_helper'

RSpec.describe "as a registered user" do

  context "I can leave a review for an item" do
    it "by clicking a link on my order page" do
      user = create(:user)
      merchant = create(:merchant)
      item = create(:item, user: merchant)
      order = create(:order, user: user, status: 1)
      order_item = create(:fulfilled_order_item, order: order, item: item)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      visit profile_order_path(order)

      within "#oitem-#{order_item.id}" do
        click_link("Review This Item")
      end
      save_and_open_page
      expect(current_path).to eq(new_order_item_review_path(order_item))
    end
  end

end
