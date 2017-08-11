class Token < ApplicationRecord
  belongs_to :user
  attr_accessor :token
end
