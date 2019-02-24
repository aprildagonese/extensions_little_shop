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

      expect(current_path).to eq(new_review_path)
    end

    it "by submitting a review form" do
      user = create(:user)
      merchant = create(:merchant)
      item = create(:item, user: merchant)
      order = create(:order, user: user, status: 1)
      order_item = create(:fulfilled_order_item, order: order, item: item)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      visit new_review_path(order_item: order_item)
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

  context "I can see all of my reviews" do
    it "by clicking a link from my profile orders page" do
      user = create(:user)
      merchant = create(:merchant)
      item = create(:item, user: merchant)
      order = create(:order, user: user, status: 1)
      order2 = create(:order, user: user, status: 1)
      order_item = create(:fulfilled_order_item, order: order, item: item)
      order_item2 = create(:fulfilled_order_item, order: order2, item: item)
      review = create(:review, user: user, order_item: order_item)
      review2 = create(:review, user: user, order_item: order_item2)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      visit profile_path
      click_on("My Reviews")

      expect(current_path).to eq(reviews_path)

      within "#review-#{review.id}" do
        expect(page).to have_content("Title: #{review.title}")
        expect(page).to have_content("Description: #{review.description}")
        expect(page).to have_content("Rating: #{review.rating}")
        expect(page).to_not have_content("Updated on:")
        expect(page).to have_button("Edit This Review")
      end

      within "#review-#{review2.id}" do
        expect(page).to have_content("Title: #{review2.title}")
        expect(page).to have_content("Description: #{review2.description}")
        expect(page).to have_content("Rating: #{review2.rating}")
        expect(page).to_not have_content("Updated on:")
        expect(page).to have_button("Edit This Review")
      end
    end

    context "I can edit one of my reviews" do
      it "from the reviews index" do
        user = create(:user)
        merchant = create(:merchant)
        item = create(:item, user: merchant)
        order = create(:order, user: user, status: 1)
        order_item = create(:fulfilled_order_item, order: order, item: item)
        review = create(:review, user: user, order_item: order_item, title: "My Review")

        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
        visit profile_order_path(order)
        within "#oitem-#{order_item.id}" do
          click_button("Edit This Review")
        end

        expect(current_path).to eq(edit_review_path(review))
      end

      it "from the order page" do
        user = create(:user)
        merchant = create(:merchant)
        item = create(:item, user: merchant)
        order = create(:order, user: user, status: 1)
        order_item = create(:fulfilled_order_item, order: order, item: item)
        review = create(:review, user: user, order_item: order_item, title: "My Review")

        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
        visit reviews_path

        within "#review-#{review.id}" do
          click_button("Edit This Review")
        end

        expect(current_path).to eq(edit_review_path(review))

        fill_in "Title", with: "Updated Review"
        click_on "Update Review"

        expect(current_path).to eq(reviews_path)
        within "#review-#{review.id}" do
          expect(page).to have_content("Updated Review")
        end

      end
    end
    context "I can delete one of my reviews" do
      it "from the reviews index" do
        user = create(:user)
        merchant = create(:merchant)
        item = create(:item, user: merchant)
        order = create(:order, user: user, status: 1)
        order_item = create(:fulfilled_order_item, order: order, item: item)
        review = create(:review, user: user, order_item: order_item, title: "My Review")

        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
        visit profile_order_path(order)
        expect(Review.count).to eq(1)
        within "#oitem-#{order_item.id}" do
          click_button("Delete This Review")
        end

        expect(Review.count).to eq(0)
        expect(current_path).to eq(reviews_path)
      end

      it "from the order page" do
        user = create(:user)
        merchant = create(:merchant)
        item = create(:item, user: merchant)
        order = create(:order, user: user, status: 1)
        order_item = create(:fulfilled_order_item, order: order, item: item)
        review = create(:review, user: user, order_item: order_item, title: "My Review")

        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
        visit reviews_path
        expect(Review.count).to eq(1)

        within "#review-#{review.id}" do
          click_button("Delete This Review")
        end

        expect(Review.count).to eq(0)
        expect(current_path).to eq(reviews_path)
      end
    end
  end

end
