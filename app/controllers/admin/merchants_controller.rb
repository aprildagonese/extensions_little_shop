class Admin::MerchantsController < Admin::BaseController
  def show
    @merchant = User.find(params[:id])
    if @merchant.default?
      redirect_to admin_user_path(@merchant)
    else
      render :'/merchants/show'
    end
  end

  def edit
    @user = User.find(params[:id])
    @form_path = [:admin, @user]
    render :'/users/edit'
  end

  def update
    @user = User.find(params[:id])
    @form_path = [:admin, @user]
    if @user.update(user_params)
      flash[:success] = "Profile has been updated"
      redirect_to admin_user_path(@user)
    end
  end

  def downgrade
    user = User.find(params[:id])
    user.role = :default
    user.save
    redirect_to merchants_path
  end

  def enable
    set_user_active(true)
  end

  def disable
    set_user_active(false)
  end

  private

  def set_user_active(state)
    user = User.find(params[:id])
    user.active = state
    user.save
    redirect_to merchants_path
  end
end
