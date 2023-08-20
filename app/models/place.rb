class Place < ApplicationRecord
   def self.ransackable_attributes(auth_object = nil)
    ["store_cont","name_eq"]
   end
end
