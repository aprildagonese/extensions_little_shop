class ReviewsController < ApplicationController
  before_action :require_user, only: [:new, :create]

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

  def edit
    @review = Review.find(params[:id])
    @order_item = @review.order_item
  end

  def update
    @order_item = OrderItem.find(params[:order_item])
    @review = @order_item.review
    if @review.update(review_params)
      flash[:success] = "Your review has been updated."
      redirect_to reviews_path
    else
      flash[:alert] = "Your review could not be updated. Please try again."
      render :edit
    end
  end

  def destroy
    @review = Review.find(params[:id])
    if @review.delete
      flash[:success] = "Your review has been deleted."
      redirect_to reviews_path
    else
      flash[:alert] = "Your review could not be deleted. Please try again."
      redirect_to reviews_path
    end
  end

  private

  def review_params
    params.require(:review).permit(:title, :description, :rating, :order_item)
  end
end
