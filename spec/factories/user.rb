FactoryBot.define do
  factory :user do
    email { "test@example.com" }
    password { "password" }
  end

  it "複数のユーザー登録" do
    user1 = FactoryBot.create(:user)
    user2 = FactoryBot.create(:user)
  end
end
