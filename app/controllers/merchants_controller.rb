class MerchantsController < ApplicationController
  before_action :require_merchant, only: [:show]

  def index
    if current_admin?
      @merchants = User.where(role: 1)
    else
      @merchants = User.active_merchants
    end
    @top_three_merchants_by_revenue = @merchants.top_merchants_by_revenue(3)
    @top_three_merchants_by_fulfillment = @merchants.top_merchants_by_fulfillment_time(3)
    @bottom_three_merchants_by_fulfillment = @merchants.bottom_merchants_by_fulfillment_time(3)
    @top_states_by_order_count = User.top_user_states_by_order_count(3)
    @top_cities_by_order_count = User.top_user_cities_by_order_count(3)
    @top_orders_by_items_shipped = Order.sorted_by_items_shipped(3)
    #-------
    @top_merchants_by_qty_current_month = User.merchants_by_qty_sold_this_month
    @top_merchants_by_qty_last_month = User.merchants_by_qty_sold_last_month
    @top_merchants_by_revenue_this_month = User.merchants_by_revenue_this_month
    @top_merchants_by_revenue_last_month = User.merchants_by_revenue_last_month
    if current_reguser?
      @top_merchants_to_my_state = User.merchants_by_state_by_fulfillment_time(current_user.state)
      #@top_merchants_to_my_city = User.merchants_by_city_by_fulfillment_time(current_user.state, current_user.city)
    end 
  end

  def show
    @merchant = current_user
    @pending_orders = Order.pending_orders_for_merchant(current_user.id)
  end
end
