# spec/factories/umarepos.rb
FactoryBot.define do
  factory :umarepo do
    title { "Sample Title" }
    curator { "Sample Curator" }
    comment { "Sample Comment" }
    image { "sample_image.jpg" }
    association :user
    association :cook
  end
end
