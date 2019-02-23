class ReviewsController < ApplicationController
  def new
    @order_item = OrderItem.find(params[:order_item_id])
    @review = Review.new
  end
end
