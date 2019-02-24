class ReviewsController < ApplicationController
  def new
    @order_item = OrderItem.find(params[:order_item])
    @review = Review.new
  end

  def create
    @order_item = OrderItem.find(params[:order_item])
    @review = Review.new(review_params)
    @review.update(user_id: current_user.id, order_item_id: params[:order_item])
    if @review.save
      flash[:message] = "Your review has been created."
      redirect_to profile_order_path(@order_item.order)
    else
      flash[:alert] = "There was a problem saving your review. Please try again."
      render :new
    end
  end

  def index
    @reviews = Review.my_reviews(current_user)
  end

  private

  def review_params
    params.require(:review).permit(:title, :description, :rating, :order_item)
  end
end
