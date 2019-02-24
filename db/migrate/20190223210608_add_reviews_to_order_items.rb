class AddReviewsToOrderItems < ActiveRecord::Migration[5.1]
  def change
    add_reference(:order_items, :review, foreign_key: {to_table: :reviews})
  end
end
