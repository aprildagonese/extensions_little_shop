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
        click_button("Review This Item")
      end

      expect(current_path).to eq(new_order_item_review_path(order_item))
    end

    it "by submitting a review form" do
      user = create(:user)
      merchant = create(:merchant)
      item = create(:item, user: merchant)
      order = create(:order, user: user, status: 1)
      order_item = create(:fulfilled_order_item, order: order, item: item)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      visit new_order_item_review_path(order_item)
      fill_in "Title", with: "Great item!"
      fill_in "Description", with: "This item was exactly what I needed."
      fill_in "Rating", with: 5

      click_on "Create Review"
      
      review = Review.last

      expect(current_path).to eq(profile_order_path(order))
      expect(page).to have_content("Your review has been created.")
      expect(page).to_not have_button("Review This Item")
      expect(page).to have_content("Your Review: #{review.title}")
      expect(page).to have_content("#{review.description}")
      expect(page).to have_content("Your Rating: #{review.rating}")
      expect(page).to have_button("Edit This Review")
    end
  end

end
