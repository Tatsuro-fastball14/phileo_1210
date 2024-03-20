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
  has_many :favorite
  has_many :umarepos,through: :favorite
  def subscriber?
    true
  end
  
  extend Enumerize

  enumerize :status, in: [:student, :employed, :retired], skip_validations: lambda { |user| user.new_record? }
  enumerize :rank, in: [:user, :admin], skip_validations: true
  enumerize :rank, in: [:user, :admin], default: :user
 
end


 