class Administrator < ApplicationRecord
  belongs_to :user
  has_many :user_registration_forms, dependent: :delete_all, foreign_key: 'admin_id', inverse_of: :admin
end
