require 'rails_helper'

RSpec.describe 'admin users index workflow', type: :feature do
  before :each do
    @admin = create(:admin)
  end
  describe 'shows basic information' do
    before :each do
      @active_users = create_list(:user, 3)
      @inactive_users = create_list(:inactive_user, 3)
      @merchants = create_list(:merchant, 3)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin)
    end
    it 'should show users and not merchants' do
      visit admin_users_path

      @active_users.each do |user|
        within "#user-#{user.id}" do
          expect(page).to have_link(user.name)
          expect(page).to have_content("Registration Date: #{user.created_at.to_date.to_s}")
          expect(page).to have_button('Disable')
          expect(page).to_not have_button('Enable')
        end
      end
      @inactive_users.each do |user|
        within "#user-#{user.id}" do
          expect(page).to have_link(user.name)
          expect(page).to have_content("Registration Date: #{user.created_at.to_date.to_s}")
          expect(page).to_not have_button('Disable')
          expect(page).to have_button('Enable')
        end
      end
      @merchants.each do |merchant|
        expect(page).to_not have_css("#user-#{merchant.id}")
      end

      click_link @active_users[0].name
      expect(current_path).to eq(admin_user_path(@active_users[0]))
    end
  end

  describe 'allows toggling active/inactive state of user accounts' do
    it 'makes an active user inactive' do
      active_user = create(:user)

      login_as(@admin)

      visit admin_users_path

      within "#user-#{active_user.id}" do
        click_button 'Disable'
      end

      within "#user-#{active_user.id}" do
        expect(page).to_not have_button('Disable')
        expect(page).to have_button('Enable')
      end

      visit logout_path
      login_as(active_user)

      expect(page).to have_content('Your account is inactive, contact an admin for help Login Email Password')
    end

    it 'makes an inactive user active' do
      inactive_user = create(:inactive_user)

      login_as(@admin)

      visit admin_users_path

      within "#user-#{inactive_user.id}" do
        click_button 'Enable'
      end

      within "#user-#{inactive_user.id}" do
        expect(page).to have_button('Disable')
        expect(page).to_not have_button('Enable')
      end

      visit logout_path
      login_as(inactive_user)

      expect(current_path).to eq(profile_path)
    end
  end
end
