class User < ApplicationRecord
  has_secure_password

  enum role: [:default, :merchant, :admin]

  # as a user
  has_many :orders
  has_many :order_items, through: :orders
  has_many :reviews
  # as a merchant
  has_many :items, foreign_key: 'merchant_id'

  validates_presence_of :name, :address, :city, :state, :zip
  validates :email, presence: true, uniqueness: true

  def self.active_merchants
    where(role: "merchant", active: true)
  end

  def self.top_merchants_by_revenue(limit)
    merchants_sorted_by_revenue.limit(limit)
  end

  def self.top_merchants_by_fulfillment_time(limit)
    merchants_sorted_by_fulfillment_time(limit)
  end

  def self.bottom_merchants_by_fulfillment_time(limit)
    merchants_sorted_by_fulfillment_time("DESC", limit)
  end

  def self.top_user_states_by_order_count(limit)
    self.joins(:orders)
        .where(orders: {status: 1})
        .group(:state)
        .select('users.state, count(orders.id) AS order_count')
        .order('order_count DESC')
        .limit(limit)
  end

  def self.top_user_cities_by_order_count(limit)
    self.joins(:orders)
        .where(orders: {status: 1})
        .group(:state, :city)
        .select('users.city, users.state, count(orders.id) AS order_count')
        .order('order_count DESC')
        .limit(limit)
  end

  def self.merchants_sorted_by_revenue
    self.joins(:items)
        .joins('join order_items on items.id = order_items.item_id')
        .joins('join orders on orders.id = order_items.order_id')
        .where('orders.status = 1')
        .where('order_items.fulfilled = true')
        .group(:id)
        .select('users.*, sum(order_items.quantity * order_items.price) AS total')
        .order("total DESC")
  end

  def self.merchants_sorted_by_fulfillment_time(order = "ASC", limit)
    self.joins(:items)
        .joins('join order_items on items.id = order_items.item_id')
        .joins('join orders on orders.id = order_items.order_id')
        .where('orders.status = 1')
        .where('order_items.fulfilled = true')
        .group(:id)
        .select('users.*, avg(order_items.updated_at - order_items.created_at) AS fulfillment_time')
        .order("fulfillment_time #{order}")
        .limit(limit)
  end

  def self.merchants_by_state_by_fulfillment_time(state)
    merchant_ids = Item.joins(:order_items)
                       .joins(:orders)
                       .joins("join users ON orders.user_id = users.id")
                       .where(order_items: {fulfilled: true})
                       .where(users: {state: state})
                       .distinct
                       .pluck(:merchant_id)
    merchants = User.joins(:items)
                    .joins("join order_items ON items.id = order_items.item_id")
                    .group(:id)
                    .select('users.*, avg(order_items.updated_at - order_items.created_at) AS fulfillment_time')
                    .where(id: merchant_ids)
                    .order("fulfillment_time asc")
                    .limit(5)
  end

  def self.merchants_by_city_by_fulfillment_time(city, state)
    merchant_ids = Item.joins(:order_items)
                       .joins(:orders)
                       .joins("join users ON orders.user_id = users.id")
                       .where(order_items: {fulfilled: true})
                       .where(users: {state: state})
                       .where(users: {city: city})
                       .distinct
                       .pluck(:merchant_id)
    merchants = User.joins(:items)
                    .joins("join order_items ON items.id = order_items.item_id")
                    .group(:id)
                    .select('users.*, avg(order_items.updated_at - order_items.created_at) AS fulfillment_time')
                    .where(id: merchant_ids)
                    .order("fulfillment_time asc")
                    .limit(5)
  end

  def self.merchants_by_qty_sold_this_month
    self.joins(:items)
        .joins('join order_items on items.id = order_items.item_id')
        .joins('join orders on orders.id = order_items.order_id')
        .where('orders.status = 1')
        .where('order_items.fulfilled = true')
        .where('order_items.created_at > ? AND order_items.created_at < ?', Date.today.beginning_of_month, Date.today.end_of_month)
        .group(:id)
        .select('users.*, sum(order_items.quantity) AS qty_sold')
        .order("qty_sold DESC")
        .limit(10)
  end

  def self.merchants_by_qty_sold_last_month
    self.joins(:items)
        .joins('join order_items on items.id = order_items.item_id')
        .joins('join orders on orders.id = order_items.order_id')
        .where('orders.status = 1')
        .where('order_items.fulfilled = true')
        .where('order_items.created_at > ? AND order_items.created_at < ?', Date.today.last_month.beginning_of_month, Date.today.beginning_of_month)
        .group(:id)
        .select('users.*, sum(order_items.quantity) AS qty_sold')
        .order("qty_sold DESC")
        .limit(10)
  end

  def self.merchants_by_revenue_this_month
    self.joins(:items)
        .joins('join order_items on items.id = order_items.item_id')
        .joins('join orders on orders.id = order_items.order_id')
        .where('orders.status = 1')
        .where('order_items.fulfilled = true')
        .where('order_items.created_at > ? AND order_items.created_at < ?', Date.today.beginning_of_month, Date.today.end_of_month)
        .group(:id)
        .select('users.*, sum(order_items.quantity * order_items.price) AS revenue_this_month')
        .order("revenue_this_month DESC")
        .limit(10)
  end

  def self.merchants_by_revenue_last_month
    self.joins(:items)
        .joins('join order_items on items.id = order_items.item_id')
        .joins('join orders on orders.id = order_items.order_id')
        .where('orders.status = 1')
        .where('order_items.fulfilled = true')
        .where('order_items.created_at > ? AND order_items.created_at < ?', Date.today.last_month.beginning_of_month, Date.today.beginning_of_month)
        .group(:id)
        .select('users.*, sum(order_items.quantity * order_items.price) AS revenue_last_month')
        .order("revenue_last_month DESC")
        .limit(10)
  end

  def top_items_sold_by_quantity(limit)
    items.joins(:order_items)
         .where(order_items: {fulfilled: true})
         .select('items.id, items.name, sum(order_items.quantity) as quantity')
         .group(:id)
         .order('quantity DESC, id')
         .limit(limit)
  end

  def total_items_sold
    items.joins(:order_items)
         .where(order_items: {fulfilled: true})
         .pluck('sum(order_items.quantity)')
         .first
  end

  def total_inventory_remaining
    items.sum(:inventory)
  end

  def percent_of_items_sold
    ((total_items_sold.to_f / total_inventory_remaining.to_f)*100).round(2)
  end

  def top_states_by_items_shipped(limit)
    items.joins(:order_items)
         .joins('join orders on orders.id = order_items.order_id')
         .joins('join users on users.id = orders.user_id')
         .where(order_items: {fulfilled: true})
         .group('users.state')
         .select('users.state, sum(order_items.quantity) AS quantity')
         .order('quantity DESC')
         .limit(limit)
  end

  def top_cities_by_items_shipped(limit)
    items.joins(:order_items)
         .joins('join orders on orders.id = order_items.order_id')
         .joins('join users on users.id = orders.user_id')
         .where(order_items: {fulfilled: true})
         .group('users.state, users.city')
         .select('users.state, users.city, sum(order_items.quantity) AS quantity')
         .order('quantity DESC')
         .limit(limit)
  end

  def top_user_by_order_count
    items.joins(:order_items)
         .joins('join orders on orders.id = order_items.order_id')
         .joins('join users on users.id = orders.user_id')
         .where(order_items: {fulfilled: true})
         .group('users.id')
         .select('users.name, count(orders.id) AS count')
         .order('count DESC')
         .limit(1).first
  end

  def top_user_by_item_count
    items.joins(:order_items)
         .joins('join orders on orders.id = order_items.order_id')
         .joins('join users on users.id = orders.user_id')
         .where(order_items: {fulfilled: true})
         .group('users.id')
         .select('users.name, sum(order_items.quantity) AS quantity')
         .order('quantity DESC')
         .limit(1).first
  end

  def top_users_by_money_spent(limit)
    items.joins(:order_items)
         .joins('join orders on orders.id = order_items.order_id')
         .joins('join users on users.id = orders.user_id')
         .where(order_items: {fulfilled: true})
         .group('users.id')
         .select('users.name, sum(order_items.quantity * order_items.price) AS total')
         .order('total DESC')
         .limit(limit)
  end
end
