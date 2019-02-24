require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of :email }
    it { should validate_uniqueness_of :email }
    it { should validate_presence_of :name }
    it { should validate_presence_of :address }
    it { should validate_presence_of :city }
    it { should validate_presence_of :state }
    it { should validate_presence_of :zip }
  end

  describe 'relationships' do
    # as user
    it { should have_many :orders }
    it { should have_many(:order_items).through(:orders)}
    it {should have_many :reviews }
    # as merchant
    it { should have_many :items }
  end

  describe 'class methods' do
    it ".active_merchants" do
      active_merchants = create_list(:merchant, 3)
      inactive_merchant = create(:inactive_merchant)

      expect(User.active_merchants).to eq(active_merchants)
    end

    it ".top_merchants_by_qty_sold" do
      u1, u2, u3 = create_list(:user, 3)
      @m1, @m2, @m3, @m4, @m5, @m6, @m7, @m8, @m9, @m10, @m11, @m12, @m13 = create_list(:merchant, 13)
      i1 = create(:item, merchant_id: @m1.id)
      i2 = create(:item, merchant_id: @m2.id)
      i3 = create(:item, merchant_id: @m3.id)
      i4 = create(:item, merchant_id: @m4.id)
      i5 = create(:item, merchant_id: @m5.id)
      i6 = create(:item, merchant_id: @m6.id)
      i7 = create(:item, merchant_id: @m7.id)
      i8 = create(:item, merchant_id: @m8.id)
      i9 = create(:item, merchant_id: @m9.id)
      i10 = create(:item, merchant_id: @m10.id)
      i11 = create(:item, merchant_id: @m11.id)
      i12 = create(:item, merchant_id: @m12.id)
      i13 = create(:item, merchant_id: @m13.id)
      o1 = create(:completed_order, user: u1)
      o2 = create(:completed_order, user: u1)
      o3 = create(:completed_order, user: u1)
      o4 = create(:completed_order, user: u1)
      o5 = create(:cancelled_order, user: u2)
      o6 = create(:completed_order, user: u2)
      o7 = create(:completed_order, user: u2)
      o8 = create(:completed_order, user: u2)
      o9 = create(:completed_order, user: u3)
      o10 = create(:completed_order, user: u3)
      o11 = create(:completed_order, user: u3)
      o12 = create(:completed_order, user: u3)
      o13 = create(:completed_order, user: u3)
      oi1 = create(:fulfilled_order_item, item: i1, order: o1, created_at: 29.days.ago, quantity: 11)
      oi2 = create(:fulfilled_order_item, item: i2, order: o2, created_at: 24.days.ago, quantity: 7)
      oi3 = create(:fulfilled_order_item, item: i3, order: o3, created_at: 27.days.ago, quantity: 12)
      oi4 = create(:order_item, item: i4, order: o4, created_at: 4.days.ago, quantity: 8)
      oi5 = create(:order_item, item: i5, order: o5, created_at: 5.days.ago, quantity: 13)
      oi6 = create(:fulfilled_order_item, item: i6, order: o6, created_at: 3.days.ago, quantity: 3)
      oi7 = create(:fulfilled_order_item, item: i7, order: o7, created_at: 28.days.ago, quantity: 2)
      oi8 = create(:fulfilled_order_item, item: i8, order: o8, created_at: 2.days.ago, quantity: 9)
      oi9 = create(:fulfilled_order_item, item: i9, order: o9, created_at: 29.days.ago, quantity: 4)
      oi10 = create(:fulfilled_order_item, item: i10, order: o10, created_at: 29.days.ago, quantity: 6)
      oi11 = create(:fulfilled_order_item, item: i11, order: o11, created_at: 2.days.ago, quantity: 1)
      oi12 = create(:fulfilled_order_item, item: i12, order: o12, created_at: 25.days.ago, quantity: 5)
      oi13 = create(:fulfilled_order_item, item: i13, order: o13, created_at: 2.days.ago, quantity: 10)

      expected_current_month = [@m5, @m13, @m8, @m4, @m6, @m11]
      expected_last_month = [@m3, @m1, @m2, @m10, @m12, @m9, @m7]

      expect(User.merchants_by_qty_sold_this_month).to eq(expected_current_month)
      expect(User.merchants_by_qty_sold_this_month.first.qty_sold).to eq(13)
      expect(User.merchants_by_qty_sold_last_month).to eq(expected_last_month)
      expect(User.merchants_by_qty_sold_last_month.first.qty_sold).to eq(12)
    end

    describe "statistics" do
      before :each do
        u1 = create(:user, state: "CO", city: "Fairfield")
        u2 = create(:user, state: "OK", city: "OKC")
        u3 = create(:user, state: "IA", city: "Fairfield")
        u4 = create(:user, state: "IA", city: "Des Moines")
        u5 = create(:user, state: "IA", city: "Des Moines")
        u6 = create(:user, state: "IA", city: "Des Moines")
        @m1, @m2, @m3, @m4, @m5, @m6, @m7 = create_list(:merchant, 7)
        i1 = create(:item, merchant_id: @m1.id)
        i2 = create(:item, merchant_id: @m2.id)
        i3 = create(:item, merchant_id: @m3.id)
        i4 = create(:item, merchant_id: @m4.id)
        i5 = create(:item, merchant_id: @m5.id)
        i6 = create(:item, merchant_id: @m6.id)
        i7 = create(:item, merchant_id: @m7.id)
        o1 = create(:completed_order, user: u1)
        o2 = create(:completed_order, user: u2)
        o3 = create(:completed_order, user: u3)
        o4 = create(:completed_order, user: u1)
        o5 = create(:cancelled_order, user: u5)
        o6 = create(:completed_order, user: u6)
        o7 = create(:completed_order, user: u6)
        oi1 = create(:fulfilled_order_item, item: i1, order: o1, created_at: 1.days.ago)
        oi2 = create(:fulfilled_order_item, item: i2, order: o2, created_at: 7.days.ago)
        oi3 = create(:fulfilled_order_item, item: i3, order: o3, created_at: 6.days.ago)
        oi4 = create(:order_item, item: i4, order: o4, created_at: 4.days.ago)
        oi5 = create(:order_item, item: i5, order: o5, created_at: 5.days.ago)
        oi6 = create(:fulfilled_order_item, item: i6, order: o6, created_at: 3.days.ago)
        oi7 = create(:fulfilled_order_item, item: i7, order: o7, created_at: 2.days.ago)
      end
      it ".merchants_sorted_by_revenue" do
        expect(User.merchants_sorted_by_revenue).to eq([@m7, @m6, @m3, @m2, @m1])
      end

      it ".top_merchants_by_revenue()" do
        expect(User.top_merchants_by_revenue(3)).to eq([@m7, @m6, @m3])
      end

      it ".merchants_sorted_by_fulfillment_time" do
        expect(User.merchants_sorted_by_fulfillment_time(10)).to eq([@m1, @m7, @m6, @m3, @m2])
      end

      it ".top_merchants_by_fulfillment_time" do
        expect(User.top_merchants_by_fulfillment_time(3)).to eq([@m1, @m7, @m6])
      end

      it ".bottom_merchants_by_fulfillment_time" do
        expect(User.bottom_merchants_by_fulfillment_time(3)).to eq([@m2, @m3, @m6])
      end

      it ".top_user_states_by_order_count" do
        expect(User.top_user_states_by_order_count(3)[0].state).to eq("IA")
        expect(User.top_user_states_by_order_count(3)[0].order_count).to eq(3)
        expect(User.top_user_states_by_order_count(3)[1].state).to eq("CO")
        expect(User.top_user_states_by_order_count(3)[1].order_count).to eq(2)
        expect(User.top_user_states_by_order_count(3)[2].state).to eq("OK")
        expect(User.top_user_states_by_order_count(3)[2].order_count).to eq(1)
      end

      it ".top_user_cities_by_order_count" do
        expect(User.top_user_cities_by_order_count(3)[0].state).to eq("CO")
        expect(User.top_user_cities_by_order_count(3)[0].city).to eq("Fairfield")
        expect(User.top_user_cities_by_order_count(3)[0].order_count).to eq(2)
        expect(User.top_user_cities_by_order_count(3)[1].state).to eq("IA")
        expect(User.top_user_cities_by_order_count(3)[1].city).to eq("Des Moines")
        expect(User.top_user_cities_by_order_count(3)[1].order_count).to eq(2)
        expect(User.top_user_cities_by_order_count(3)[2].state).to eq("IA")
        expect(User.top_user_cities_by_order_count(3)[2].city).to eq("Fairfield")
        expect(User.top_user_cities_by_order_count(3)[2].order_count).to eq(1)
      end
    end

    describe "more statistics" do
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
        @i1 = create(:item, merchant_id: @m1.id)
        @i2 = create(:item, merchant_id: @m2.id)
        @i3 = create(:item, merchant_id: @m3.id)
        @i4 = create(:item, merchant_id: @m4.id)
        @i5 = create(:item, merchant_id: @m5.id)
        @i6 = create(:item, merchant_id: @m6.id)
        @i7 = create(:item, merchant_id: @m7.id)
        @i8 = create(:item, merchant_id: @m8.id)
        @i9 = create(:item, merchant_id: @m9.id)
        @i10 = create(:item, merchant_id: @m10.id)
        @i11 = create(:item, merchant_id: @m11.id)
        @i12 = create(:item, merchant_id: @m12.id)
        @i13 = create(:item, merchant_id: @m13.id)
        @o1 = create(:completed_order, user: @u1)
        @o2 = create(:completed_order, user: @u2)
        @o3 = create(:completed_order, user: @u3)
        @o4 = create(:completed_order, user: @u4)
        @o5 = create(:cancelled_order, user: @u5)
        @o6 = create(:completed_order, user: @u6)
        @o7 = create(:completed_order, user: @u7)
        @o8 = create(:completed_order, user: @u8)
        @o9 = create(:completed_order, user: @u9)
        @o10 = create(:completed_order, user: @u10)
        @o11 = create(:completed_order, user: @u11)
        @o12 = create(:completed_order, user: @u12)
        @o13 = create(:completed_order, user: @u13)
        @oi1 = create(:fulfilled_order_item, item: @i1, order: @o1, created_at: 29.days.ago, quantity: 11)
        @oi2 = create(:fulfilled_order_item, item: @i2, order: @o2, created_at: 24.days.ago, quantity: 7)
        @oi3 = create(:fulfilled_order_item, item: @i3, order: @o3, created_at: 27.days.ago, quantity: 12)
        @oi4 = create(:order_item, item: @i4, order: @o4, created_at: 4.days.ago, quantity: 8)
        @oi5 = create(:order_item, item: @i5, order: @o5, created_at: 5.days.ago, quantity: 13)
        @oi6 = create(:fulfilled_order_item, item: @i6, order: @o6, created_at: 3.days.ago, quantity: 3)
        @oi7 = create(:fulfilled_order_item, item: @i7, order: @o7, created_at: 28.days.ago, quantity: 2)
        @oi8 = create(:fulfilled_order_item, item: @i8, order: @o8, created_at: 2.days.ago, quantity: 9)
        @oi9 = create(:fulfilled_order_item, item: @i9, order: @o9, created_at: 26.days.ago, quantity: 4)
        @oi10 = create(:fulfilled_order_item, item: @i10, order: @o10, created_at: 23.days.ago, quantity: 6)
        @oi11 = create(:fulfilled_order_item, item: @i11, order: @o11, created_at: 2.days.ago, quantity: 1)
        @oi12 = create(:fulfilled_order_item, item: @i12, order: @o12, created_at: 25.days.ago, quantity: 5)
        @oi13 = create(:fulfilled_order_item, item: @i13, order: @o13, created_at: 2.days.ago, quantity: 10)
      end

      it ".merchants_by_qty_sold_by_month" do
        expected_current_month = [@m5, @m13, @m8, @m4, @m6, @m11]
        expected_last_month = [@m3, @m1, @m2, @m10, @m12, @m9, @m7]

        expect(User.merchants_by_qty_sold_this_month).to eq(expected_current_month)
        expect(User.merchants_by_qty_sold_this_month.first.qty_sold).to eq(13)
        expect(User.merchants_by_qty_sold_last_month).to eq(expected_last_month)
        expect(User.merchants_by_qty_sold_last_month.first.qty_sold).to eq(12)
      end

      it ".merchants_by_my_location_by_fulfillment_time" do
        expected_ca = [@m1, @m4, @m9, @m11, @m12]
        expected_or = [@m3, @m6, @m7, @m8]
        binding.pry
        expect(User.merchants_by_location_by_fulfillment_time("state = CA")).to eq(expected_ca)
        expect(User.merchants_by_location_by_fulfillment_time("state = OR")).to eq(expected_or)
      end

      it ".top_merchants_by_my_city_by_fulfillment_time" do
        expect(User.top_merchants_by_fulfillment_time(3)).to eq([@m1, @m7, @m6])
      end
    end
  end

  describe 'instance methods' do
    before :each do
      @u1 = create(:user, state: "CO", city: "Fairfield")
      @u2 = create(:user, state: "OK", city: "OKC")
      @u3 = create(:user, state: "IA", city: "Fairfield")
      u4 = create(:user, state: "IA", city: "Des Moines")
      u5 = create(:user, state: "IA", city: "Des Moines")
      u6 = create(:user, state: "IA", city: "Des Moines")
      @m1 = create(:merchant)
      @m2 = create(:merchant)
      @i1 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i2 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i3 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i4 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i5 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i6 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i7 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i9 = create(:item, merchant_id: @m1.id, inventory: 20)
      @i8 = create(:item, merchant_id: @m2.id, inventory: 20)
      o1 = create(:completed_order, user: @u1)
      o2 = create(:completed_order, user: @u2)
      o3 = create(:completed_order, user: @u3)
      o4 = create(:completed_order, user: @u1)
      o5 = create(:cancelled_order, user: u5)
      o6 = create(:completed_order, user: u6)
      @oi1 = create(:order_item, item: @i1, order: o1, quantity: 2, created_at: 1.days.ago)
      @oi2 = create(:order_item, item: @i2, order: o2, quantity: 8, created_at: 7.days.ago)
      @oi3 = create(:order_item, item: @i2, order: o3, quantity: 6, created_at: 7.days.ago)
      @oi4 = create(:order_item, item: @i3, order: o3, quantity: 4, created_at: 6.days.ago)
      @oi5 = create(:order_item, item: @i4, order: o4, quantity: 3, created_at: 4.days.ago)
      @oi6 = create(:order_item, item: @i5, order: o5, quantity: 1, created_at: 5.days.ago)
      @oi7 = create(:order_item, item: @i6, order: o6, quantity: 2, created_at: 3.days.ago)
      @oi1.fulfill
      @oi2.fulfill
      @oi3.fulfill
      @oi4.fulfill
      @oi5.fulfill
      @oi6.fulfill
      @oi7.fulfill
    end

    it '.top_items_sold_by_quantity' do
      expect(@m1.top_items_sold_by_quantity(5)[0].name).to eq(@i2.name)
      expect(@m1.top_items_sold_by_quantity(5)[0].quantity).to eq(14)
      expect(@m1.top_items_sold_by_quantity(5)[1].name).to eq(@i3.name)
      expect(@m1.top_items_sold_by_quantity(5)[1].quantity).to eq(4)
      expect(@m1.top_items_sold_by_quantity(5)[2].name).to eq(@i4.name)
      expect(@m1.top_items_sold_by_quantity(5)[2].quantity).to eq(3)
      expect(@m1.top_items_sold_by_quantity(5)[3].name).to eq(@i1.name)
      expect(@m1.top_items_sold_by_quantity(5)[3].quantity).to eq(2)
      expect(@m1.top_items_sold_by_quantity(5)[4].name).to eq(@i6.name)
      expect(@m1.top_items_sold_by_quantity(5)[4].quantity).to eq(2)
    end

    it '.total_items_sold' do
      expect(@m1.total_items_sold).to eq(26)
    end

    it '.total_inventory_remaining' do
      expect(@m1.total_inventory_remaining).to eq(134)
    end

    it '.percent_of_items_sold' do
      expect(@m1.percent_of_items_sold).to eq(19.40)
    end

    it '.top_states_by_items_shipped' do
      expect(@m1.top_states_by_items_shipped(3)[0].state).to eq("IA")
      expect(@m1.top_states_by_items_shipped(3)[0].quantity).to eq(13)
      expect(@m1.top_states_by_items_shipped(3)[1].state).to eq("OK")
      expect(@m1.top_states_by_items_shipped(3)[1].quantity).to eq(8)
      expect(@m1.top_states_by_items_shipped(3)[2].state).to eq("CO")
      expect(@m1.top_states_by_items_shipped(3)[2].quantity).to eq(5)
    end

    it '.top_cities_by_items_shipped' do
      expect(@m1.top_cities_by_items_shipped(3)[0].city).to eq("Fairfield")
      expect(@m1.top_cities_by_items_shipped(3)[0].state).to eq("IA")
      expect(@m1.top_cities_by_items_shipped(3)[0].quantity).to eq(10)
      expect(@m1.top_cities_by_items_shipped(3)[1].city).to eq("OKC")
      expect(@m1.top_cities_by_items_shipped(3)[1].state).to eq("OK")
      expect(@m1.top_cities_by_items_shipped(3)[1].quantity).to eq(8)
      expect(@m1.top_cities_by_items_shipped(3)[2].city).to eq("Fairfield")
      expect(@m1.top_cities_by_items_shipped(3)[2].state).to eq("CO")
      expect(@m1.top_cities_by_items_shipped(3)[2].quantity).to eq(5)
    end

    it '.top_user_by_order_count' do
      expect(@m1.top_user_by_order_count.name).to eq(@u1.name)
      expect(@m1.top_user_by_order_count.count).to eq(2)
    end

    it '.top_user_by_item_count' do
      expect(@m1.top_user_by_item_count.name).to eq(@u3.name)
      expect(@m1.top_user_by_item_count.quantity).to eq(10)
    end

    it '.top_users_by_money_spent' do
      expect(@m1.top_users_by_money_spent(3)[0].name).to eq(@u3.name)
      expect(@m1.top_users_by_money_spent(3)[0].total).to eq(66.0)
      expect(@m1.top_users_by_money_spent(3)[1].name).to eq(@u2.name)
      expect(@m1.top_users_by_money_spent(3)[1].total).to eq(36.0)
      expect(@m1.top_users_by_money_spent(3)[2].name).to eq(@u1.name)
      expect(@m1.top_users_by_money_spent(3)[2].total).to eq(33.0)
    end
  end
end
