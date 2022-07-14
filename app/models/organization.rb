class Organization < ApplicationRecord
  validates :name, presence: true
  has_many :addresses
  has_many :filings
  has_many :received_awards, inverse_of: :recipient
  has_many :awards, through: :filings

  scope :filer_orgs, -> {where(is_filer: true)}
  scope :receiver_orgs, -> {where(is_receiver: true)}
end
