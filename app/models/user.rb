class User < ApplicationRecord
  user = User.new
  user.authentication_keys  = [:name]
end
