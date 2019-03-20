require 'factory_bot_rails'

include FactoryBot::Syntax::Methods

OrderItem.destroy_all
Order.destroy_all
Item.destroy_all
User.destroy_all

admin = create(:admin, name: "Admin 1")
user = create(:user, name: "User 1")
merchant_1 = create(:merchant, name: "Merchant 1")

merchant_2 = create(:merchant, name: "Merhchant 2")
merchant_3 = create(:merchant, name: "Merchant 3")
merchant_4 = create(:merchant, name: "Merchant 4")

inactive_merchant_1 = create(:inactive_merchant, name: "Inactive Merchant1")
inactive_user_1 = create(:inactive_user, name: "Inactive User1")

item_1 = create(:item, user: merchant_1)
item_2 = create(:item, user: merchant_2)
item_3 = create(:item, user: merchant_3)
item_4 = create(:item, user: merchant_4)
create_list(:item, 3, user: merchant_1)

inactive_item_1 = create(:inactive_item, user: merchant_1)
inactive_item_2 = create(:inactive_item, user: inactive_merchant_1)

Random.new_seed
rng = Random.new

order = create(:completed_order, user: user, created_at: 30.days.ago, updated_at: 30.days.ago)
create(:fulfilled_order_item, order: order, item: item_1, price: 1, quantity: 1, created_at: 30.days.ago, updated_at: 29.days.ago)
create(:fulfilled_order_item, order: order, item: item_2, price: 2, quantity: 1, created_at: 30.days.ago, updated_at: 28.days.ago)
create(:fulfilled_order_item, order: order, item: item_3, price: 3, quantity: 1, created_at: 30.days.ago, updated_at: 29.days.ago)
create(:fulfilled_order_item, order: order, item: item_4, price: 4, quantity: 1, created_at: 30.days.ago, updated_at: 28.days.ago)

# pending order
order = create(:order, user: user)
create(:order_item, order: order, item: item_1, price: 1, quantity: 1)
create(:fulfilled_order_item, order: order, item: item_2, price: 2, quantity: 1, created_at: (rng.rand(23)+1).days.ago, updated_at: rng.rand(23).hours.ago)

order = create(:cancelled_order, user: user)
create(:order_item, order: order, item: item_2, price: 2, quantity: 1, created_at: (rng.rand(23)+1).hour.ago, updated_at: rng.rand(59).minutes.ago)
create(:order_item, order: order, item: item_3, price: 3, quantity: 1, created_at: (rng.rand(23)+1).hour.ago, updated_at: rng.rand(59).minutes.ago)

order = create(:completed_order, user: user)
create(:fulfilled_order_item, order: order, item: item_1, price: 1, quantity: 1, created_at: (rng.rand(4)+1).days.ago, updated_at: rng.rand(59).minutes.ago)
create(:fulfilled_order_item, order: order, item: item_2, price: 2, quantity: 1, created_at: (rng.rand(23)+1).hour.ago, updated_at: rng.rand(59).minutes.ago)

#Test Users
test_user = create(:user, email: "user@test.com", password: "test", name: "Test User")
test_merch = create(:user, email: "merchant@test.com", password: "test", role: 1, name: "Test Merch")
test_admin = create(:user, email: "admin@test.com", password: "test", role: 2, name: "Test Admin")
item1, item2, item3, item4 = create_list(:item, 4, user: test_merch)
test_order = create(:order, user: test_user, status: 1)
test_oi1 = create(:fulfilled_order_item, item: item1, order: test_order)
test_oi2 = create(:fulfilled_order_item, item: item2, order: test_order)
test_oi3 = create(:fulfilled_order_item, item: item3, order: test_order)
test_oi4 = create(:fulfilled_order_item, item: item4, order: test_order)

#Fulfilled Orders w/Reviews From Last Month
merchant1 = create(:merchant, name: "Merchant 5")
item1, item2, item3, item4 = create_list(:item, 4, user: merchant1)
order1, order2, order3 = create_list(:order, 3, user: test_user, status: 1, created_at: 30.days.ago)
oi1 = create(:fulfilled_order_item, order: order1, item: item1, created_at: 30.days.ago, updated_at: 30.days.ago)
oi2 = create(:fulfilled_order_item, order: order2, item: item2, created_at: 30.days.ago, updated_at: 29.days.ago)
oi3 = create(:fulfilled_order_item, order: order3, item: item3, created_at: 30.days.ago, updated_at: 28.days.ago)
order4 = create(:order, user: user, created_at: 30.days.ago, status: 1, updated_at: 29.days.ago)
oi4 = create(:fulfilled_order_item, order: order4, item: item1, created_at: 30.days.ago, updated_at: 25.days.ago)
order5 = create(:order, user: test_user, created_at: 30.days.ago, status: 1, updated_at: 29.days.ago)
oi5 = create(:fulfilled_order_item, order: order5, item: item1, created_at: 30.days.ago, updated_at: 27.days.ago)
review1 = create(:review, user: test_user, order_item: oi1)
review2 = create(:review, user: test_user, order_item: oi2)
review3 = create(:review, user: test_user, order_item: oi3)
review4 = create(:review, user: user, order_item: oi4)
review5 = create(:review, user: test_user, order_item: oi5)

#Fulfilled Orders w/Reviews From This Month
merchant1 = create(:merchant, name: "Merchant 6")
item5, item6, item7, item8 = create_list(:item, 4, user: merchant1)
order6, order7, order8 = create_list(:order, 3, user: test_user, status: 1, created_at: 3.days.ago)
oi6 = create(:fulfilled_order_item, order: order6, item: item5, created_at: 3.days.ago, updated_at: 2.days.ago)
oi7 = create(:fulfilled_order_item, order: order7, item: item6, created_at: 3.days.ago, updated_at: 2.days.ago)
oi8 = create(:fulfilled_order_item, order: order8, item: item_2, created_at: 3.days.ago, updated_at: 2.days.ago)
order9 = create(:order, user: user, created_at: 5.days.ago, status: 1, updated_at: 4.days.ago)
oi9 = create(:fulfilled_order_item, order: order9, item: item_1, created_at: 5.days.ago, updated_at: 4.days.ago)
order10 = create(:order, user: test_user, created_at: 8.days.ago, status: 1, updated_at: 7.days.ago)
oi10 = create(:fulfilled_order_item, order: order10, item: item5, created_at: 8.days.ago, updated_at: 7.days.ago)
review6 = create(:review, user: test_user, order_item: oi6)
review7 = create(:review, user: test_user, order_item: oi7)
review8 = create(:review, user: test_user, order_item: oi8)
review9 = create(:review, user: user, order_item: oi9)
review10 = create(:review, user: test_user, order_item: oi10)




puts 'seed data finished'
puts "Users created: #{User.count.to_i}"
puts "Orders created: #{Order.count.to_i}"
puts "Items created: #{Item.count.to_i}"
puts "OrderItems created: #{OrderItem.count.to_i}"
puts "Reviews created: #{Review.count.to_i}"
