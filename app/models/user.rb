class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
          :rememberable, :validatable
         has_many :stocks
end
