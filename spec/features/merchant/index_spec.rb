require 'rails_helper'

RSpec.describe "merchant index workflow", type: :feature do
  describe "As a visitor" do
    describe "displays all active merchant information" do
      before :each do
        @merchant_1, @merchant_2 = create_list(:merchant, 2)
        @inactive_merchant = create(:inactive_merchant)
      end
      scenario 'as a visitor' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(nil)
        @am_admin = false
      end
      scenario 'as an admin' do
        admin = create(:admin)
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)
        @am_admin = true
      end
      after :each do
        visit merchants_path

        within("#merchant-#{@merchant_1.id}") do
          expect(page).to have_content(@merchant_1.name)
          expect(page).to have_content("#{@merchant_1.city}, #{@merchant_1.state}")
          expect(page).to have_content("Registered Date: #{@merchant_1.created_at}")
          if @am_admin
            expect(page).to have_button('Disable Merchant')
          end
        end

        within("#merchant-#{@merchant_2.id}") do
          expect(page).to have_content(@merchant_2.name)
          expect(page).to have_content("#{@merchant_2.city}, #{@merchant_2.state}")
          expect(page).to have_content("Registered Date: #{@merchant_2.created_at}")
          if @am_admin
            expect(page).to have_button('Disable Merchant')
          end
        end

        if @am_admin
          within("#merchant-#{@inactive_merchant.id}") do
            expect(page).to have_button('Enable Merchant')
          end
        else
          expect(page).to_not have_content(@inactive_merchant.name)
          expect(page).to_not have_content("#{@inactive_merchant.city}, #{@inactive_merchant.state}")
        end
      end
    end

    describe 'admins can enable/disable merchants' do
      before :each do
        @merchant_1 = create(:merchant)
        @admin = create(:admin)
      end
      it 'allows an admin to disable a merchant' do
        login_as(@admin)

        visit merchants_path

        within("#merchant-#{@merchant_1.id}") do
          click_button('Disable Merchant')
        end
        expect(current_path).to eq(merchants_path)

        visit logout_path
        login_as(@merchant_1)
        expect(current_path).to eq(login_path)
        expect(page).to have_content('Your account is inactive, contact an admin for help')

        visit logout_path
        login_as(@admin)
        visit merchants_path

        within("#merchant-#{@merchant_1.id}") do
          click_button('Enable Merchant')
        end

        visit logout_path
        login_as(@merchant_1)
        expect(current_path).to eq(dashboard_path)

        visit logout_path
        login_as(@admin)
        visit merchants_path

        within("#merchant-#{@merchant_1.id}") do
          expect(page).to have_button('Disable Merchant')
        end
      end
    end

    describe "shows merchant statistics" do
      before :each do
        @u1 = create(:user, state: "CO", city: "Fairfield")
        @u3 = create(:user, state: "IA", city: "Fairfield")
        @u2 = create(:user, state: "OK", city: "OKC")
        @u4 = create(:user, state: "IA", city: "Des Moines")
        @u5 = create(:user, state: "IA", city: "Des Moines")
        @u6 = create(:user, state: "IA", city: "Des Moines")
        @m1, @m2, @m3, @m4, @m5, @m6, @m7 = create_list(:merchant, 7)
        @i1 = create(:item, merchant_id: @m1.id)
        @i2 = create(:item, merchant_id: @m2.id)
        @i3 = create(:item, merchant_id: @m3.id)
        @i4 = create(:item, merchant_id: @m4.id)
        @i5 = create(:item, merchant_id: @m5.id)
        @i6 = create(:item, merchant_id: @m6.id)
        @i7 = create(:item, merchant_id: @m7.id)
        @o1 = create(:completed_order, user: @u1)
        @o2 = create(:completed_order, user: @u2)
        @o3 = create(:completed_order, user: @u3)
        @o4 = create(:completed_order, user: @u1)
        @o5 = create(:cancelled_order, user: @u5)
        @o6 = create(:completed_order, user: @u6)
        @o7 = create(:completed_order, user: @u6)
        @oi1 = create(:fulfilled_order_item, item: @i1, order: @o1, created_at: 5.minutes.ago)
        @oi2 = create(:fulfilled_order_item, item: @i2, order: @o2, created_at: 53.5.hours.ago)
        @oi3 = create(:fulfilled_order_item, item: @i3, order: @o3, created_at: 6.days.ago)
        @oi4 = create(:order_item, item: @i4, order: @o4, created_at: 4.days.ago)
        @oi5 = create(:order_item, item: @i5, order: @o5, created_at: 5.days.ago)
        @oi6 = create(:fulfilled_order_item, item: @i6, order: @o6, created_at: 3.days.ago)
        @oi7 = create(:fulfilled_order_item, item: @i7, order: @o7, created_at: 2.hours.ago)
      end

      it "top 3 merchants by price and quantity, with their revenue" do
        visit merchants_path

        within("#top-three-merchants-revenue") do
          expect(page).to have_content("#{@m7.name}: $192.00")
          expect(page).to have_content("#{@m6.name}: $147.00")
          expect(page).to have_content("#{@m3.name}: $48.00")
        end
      end

      it "top 3 merchants who were fastest at fulfilling items in an order, with their times" do
        visit merchants_path

        within("#top-three-merchants-fulfillment") do
          expect(page).to have_content("#{@m1.name}: 00 hours")
          expect(page).to have_content("#{@m7.name}: 02 hours")
          expect(page).to have_content("#{@m2.name}: 2 days")
        end
      end

      it "worst 3 merchants who were slowest at fulfilling items in an order, with their times" do
        visit merchants_path

        within("#bottom-three-merchants-fulfillment") do
          expect(page).to have_content("#{@m3.name}: 6 days")
          expect(page).to have_content("#{@m6.name}: 3 days")
          expect(page).to have_content("#{@m2.name}: 2 days")
        end
      end

      it "top 3 states where any orders were shipped, and count of orders" do
        visit merchants_path

        within("#top-states-by-order") do
          expect(page).to have_content("IA: 3 orders")
          expect(page).to have_content("CO: 2 orders")
          expect(page).to have_content("OK: 1 order")
          expect(page).to_not have_content("OK: 1 orders")
        end
      end

      it "top 3 cities where any orders were shipped, and count of orders" do
        visit merchants_path

        within("#top-cities-by-order") do
          expect(page).to have_content("Des Moines, IA: 2 orders")
          expect(page).to have_content("Fairfield, CO: 2 orders")
          expect(page).to have_content("Fairfield, IA: 1 order")
          expect(page).to_not have_content("Fairfield, IA: 1 orders")
        end
      end

      it "top 3 orders by quantity of items shipped, plus their quantities" do
        visit merchants_path

        within("#top-orders-by-items-shipped") do
          expect(page).to have_content("Order #{@o7.id}: 16 items")
          expect(page).to have_content("Order #{@o6.id}: 14 items")
          expect(page).to have_content("Order #{@o3.id}: 8 items")
        end
      end
    end

    describe "shows merchant leaderboard" do
      before :each do
        @u1 = create(:user, city: "San Francisco", state: "CA")
        @u2 = create(:user, city: "Denver", state: "CO")
        @u3 = create(:user, city: "Portland", state: "OR")
        @u4 = create(:user, city: "San Francisco", state: "CA")
        @u5 = create(:user, city: "Fort Collins", state: "CO")
        @u6 = create(:user, city: "Portland", state: "OR")
        @u7 = create(:user, city: "Ashland", state: "OR")
        @u8 = create(:user, city: "Bend", state: "OR")
        @u9 = create(:user, city: "San Diego", state: "CA")
        @u10 = create(:user, city: "Boulder", state: "CO")
        @u11 = create(:user, city: "Santa Barbara", state: "CA")
        @u12 = create(:user, city: "San Francisco", state: "CA")
        @u13 = create(:user, city: "Breckenridge", state: "CO")
        @m1, @m2, @m3, @m4, @m5, @m6, @m7, @m8, @m9, @m10, @m11, @m12, @m13 = create_list(:merchant, 13, state: "CO")
        @i1 = create(:item, merchant_id: @m1.id, price: 1.00)
        @i2 = create(:item, merchant_id: @m2.id, price: 1.00)
        @i3 = create(:item, merchant_id: @m3.id, price: 1.00)
        @i4 = create(:item, merchant_id: @m4.id, price: 1.00)
        @i5 = create(:item, merchant_id: @m5.id, price: 1.00)
        @i6 = create(:item, merchant_id: @m6.id, price: 1.00)
        @i7 = create(:item, merchant_id: @m7.id, price: 1.00)
        @i8 = create(:item, merchant_id: @m8.id, price: 1.00)
        @i9 = create(:item, merchant_id: @m9.id, price: 1.00)
        @i10 = create(:item, merchant_id: @m10.id, price: 1.00)
        @i11 = create(:item, merchant_id: @m11.id, price: 1.00)
        @i12 = create(:item, merchant_id: @m12.id, price: 1.00)
        @i13 = create(:item, merchant_id: @m13.id, price: 1.00)
        @o1 = create(:completed_order, user: @u1, created_at: 30.days.ago)
        @o2 = create(:completed_order, user: @u2, created_at: 30.days.ago)
        @o3 = create(:completed_order, user: @u3, created_at: 30.days.ago)
        @o4 = create(:completed_order, user: @u4)
        @o5 = create(:cancelled_order, user: @u5)
        @o6 = create(:completed_order, user: @u6)
        @o7 = create(:completed_order, user: @u7, created_at: 30.days.ago)
        @o8 = create(:completed_order, user: @u8)
        @o9 = create(:completed_order, user: @u9, created_at: 30.days.ago)
        @o10 = create(:completed_order, user: @u10, created_at: 30.days.ago)
        @o11 = create(:completed_order, user: @u11)
        @o12 = create(:completed_order, user: @u12, created_at: 30.days.ago)
        @o13 = create(:completed_order, user: @u13)
        @oi1 = create(:fulfilled_order_item, item: @i1, order: @o1, created_at: 30.days.ago, updated_at: 5.days.ago, quantity: 11, price: 1.00)
        @oi2 = create(:fulfilled_order_item, item: @i2, order: @o2, created_at: 30.days.ago, quantity: 7, price: 1.00)
        @oi3 = create(:fulfilled_order_item, item: @i3, order: @o3, created_at: 30.days.ago, updated_at: 10.days.ago, quantity: 12, price: 1.00)
        @oi4 = create(:order_item, item: @i4, order: @o4, created_at: 4.days.ago, quantity: 8, price: 1.00)
        @oi5 = create(:order_item, item: @i5, order: @o5, created_at: 5.days.ago, quantity: 13, price: 1.00)
        @oi6 = create(:fulfilled_order_item, item: @i6, order: @o6, created_at: 3.days.ago, quantity: 3, price: 1.00)
        @oi7 = create(:fulfilled_order_item, item: @i7, order: @o7, created_at: 30.days.ago, updated_at: 2.days.ago, quantity: 2, price: 1.00)
        @oi8 = create(:fulfilled_order_item, item: @i8, order: @o8, created_at: 2.days.ago, quantity: 9, price: 1.00)
        @oi9 = create(:fulfilled_order_item, item: @i9, order: @o9, created_at: 30.days.ago, updated_at: 25.days.ago, quantity: 4, price: 1.00)
        @oi10 = create(:fulfilled_order_item, item: @i10, order: @o10, created_at: 30.days.ago, quantity: 6, price: 1.00)
        @oi11 = create(:fulfilled_order_item, item: @i11, order: @o11, created_at: 2.days.ago, updated_at: 1.days.ago, quantity: 1, price: 1.00)
        @oi12 = create(:fulfilled_order_item, item: @i12, order: @o12, created_at: 30.days.ago, updated_at: 27.days.ago, quantity: 5, price: 1.00)
        @oi13 = create(:fulfilled_order_item, item: @i13, order: @o13, created_at: 2.days.ago, quantity: 10, price: 1.00)
      end
      it 'shows top merchant by items sold by month' do
        visit merchants_path

        within('#top-merchants-by-qty-this-month') do
          expect(page.all('li')[0]).to have_content("#{@m13.name}: 10 items sold")
          expect(page.all('li')[1]).to have_content("#{@m8.name}: 9 items sold")
          expect(page.all('li')[2]).to have_content("#{@m6.name}: 3 items sold")
          expect(page.all('li')[3]).to have_content("#{@m11.name}: 1 item sold")
        end

        within('#top-merchants-by-qty-last-month') do
          expect(page.all('li')[0]).to have_content("#{@m3.name}: 12 items sold")
          expect(page.all('li')[1]).to have_content("#{@m1.name}: 11 items sold")
          expect(page.all('li')[2]).to have_content("#{@m2.name}: 7 items sold")
          expect(page.all('li')[3]).to have_content("#{@m10.name}: 6 items sold")
          expect(page.all('li')[4]).to have_content("#{@m12.name}: 5 items sold")
          expect(page.all('li')[5]).to have_content("#{@m9.name}: 4 items sold")
          expect(page.all('li')[6]).to have_content("#{@m7.name}: 2 items sold")
        end
      end

      it "shows top merchants by revenue by month" do
        visit merchants_path

        within('#top-merchants-by-revenue-this-month') do
          expect(page.all('li')[0]).to have_content("#{@m13.name}: $10.00 sold")
          expect(page.all('li')[1]).to have_content("#{@m8.name}: $9.00 sold")
          expect(page.all('li')[2]).to have_content("#{@m6.name}: $3.00 sold")
          expect(page.all('li')[3]).to have_content("#{@m11.name}: $1.00 sold")
        end

        within('#top-merchants-by-revenue-last-month') do
          expect(page.all('li')[0]).to have_content("#{@m3.name}: $12.00 sold")
          expect(page.all('li')[1]).to have_content("#{@m1.name}: $11.00 sold")
          expect(page.all('li')[2]).to have_content("#{@m2.name}: $7.00 sold")
          expect(page.all('li')[3]).to have_content("#{@m10.name}: $6.00 sold")
          expect(page.all('li')[4]).to have_content("#{@m12.name}: $5.00 sold")
          expect(page.all('li')[5]).to have_content("#{@m9.name}: $4.00 sold")
          expect(page.all('li')[6]).to have_content("#{@m7.name}: $2.00 sold")
        end

      end

      it 'shows top merchants to my location by fulfillment time' do
        login_as(@u1)
        visit merchants_path

        expected_ca = [@m11, @m12, @m9, @m1]
        expected_SF = [@m12, @m1]

        within('#top-merchants-my-state') do
          expect(page.all('li')[0]).to have_content("#{@m11.name}: 1 day")
          expect(page.all('li')[1]).to have_content("#{@m12.name}: 3 days")
          expect(page.all('li')[2]).to have_content("#{@m9.name}: 5 days")
          expect(page.all('li')[3]).to have_content("#{@m1.name}: 25 days")
        end

        within('#top-merchants-my-city') do
          expect(page.all('li')[0]).to have_content("#{@m12.name}: 3 days")
          expect(page.all('li')[1]).to have_content("#{@m1.name}: 25 days")
        end
      end

    end
  end
end
