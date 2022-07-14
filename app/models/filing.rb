class Filing < ApplicationRecord
  has_many :awards
  belongs_to :organization
  default_scope { order(created_at: :desc) }
end
