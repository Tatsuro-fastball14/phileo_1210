FactoryBot.define do
  factory :cook do
    store_catchcopy { "Delicious cuisine, just for you!" }
    sentence { "Experience the best food in Okinawa with our specially curated dishes." }
    address { "456 Gourmet Avenue, Okinawa" }
    phone_number { "098-765-4321" }
    store { "Okinawa Gourmet Store" }
    category { "Japanese Cuisine" }
    lat { 26.2124 }
    lng { 127.6792 }
    order { 1 }
  end
end
