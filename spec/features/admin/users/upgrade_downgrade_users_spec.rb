require 'rails_helper'

RSpec.describe 'Upgrade/Downgrade users', type: :feature do
  describe 'as an admin user' do
    before :each do
      @admin = create(:admin)
      @user = create(:user)
      @merchant = create(:merchant)
    end

    it 'upgrades a regular user to a merchant' do
      login_as(@admin)

      visit admin_users_path
      expect(page).to have_content(@user.name)

      click_button 'Upgrade to Merchant'

      expect(current_path).to eq(admin_users_path)
      expect(page).to_not have_content(@user.name)

      visit logout_path

      login_as(@user)
      expect(current_path).to eq(dashboard_path)
      visit merchants_path
      expect(page).to have_content(@user.name)
    end

    it 'downgrades a merchant to regular user' do
      login_as(@admin)

      visit merchants_path
      within "#merchant-#{@merchant.id}" do
        click_link @merchant.name
      end 
      expect(current_path).to eq(admin_merchant_path(@merchant))
      click_button 'Downgrade to User'

      expect(current_path).to eq(merchants_path)
      expect(page).to_not have_content(@merchant.name)
      visit admin_users_path
      expect(page).to have_content(@merchant.name)

      visit logout_path

      login_as(@merchant)
      expect(current_path).to eq(profile_path)
      visit merchants_path

      within '#body-content-no-nav' do
        expect(page).to_not have_content(@merchant.name)
      end
    end
  end
end
