class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
    devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
 
  has_many :cards
  has_many :Others
  has_one :subscription
  has_many :favorites
  has_many :umarepos

  def subscriber?
    true
  end
  
  extend Enumerize
  enumerize :rank, in: [:diamond, :gold,:nomal], default: :nomal
end


 