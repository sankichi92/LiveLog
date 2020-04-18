class Developer < ApplicationRecord
  belongs_to :user
  has_many :clients, dependent: :restrict_with_exception
end
