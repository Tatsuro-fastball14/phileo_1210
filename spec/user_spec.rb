# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  it "複数のユーザー登録" do
    user1 = FactoryBot.create(:user)
    user2 = FactoryBot.create(:user)
  end
end