# spec/factories/favorites.rb
FactoryBot.define do
  factory :favorite do
    association :user
    association :cook
  end
end