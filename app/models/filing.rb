class Filing < ApplicationRecord
  has_many :awards
  belongs_to :organization
  # had added this in but not sure its needed
  # default_scope { order(created_at: :desc) }
end
