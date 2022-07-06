class Filing < ApplicationRecord
  has_many :awards
  belongs_to :organization
end
