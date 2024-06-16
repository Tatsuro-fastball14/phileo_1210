FactoryBot.define do
  factory :favorite do
    association :user
    association :umarepo
  end
end