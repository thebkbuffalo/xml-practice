class Organization < ApplicationRecord
  validates :name, presence: true
  has_many :addresses
  has_many :filings
  has_many :received_awards, inverse_of: :recipient
  has_many :awards, through: :filings
end
