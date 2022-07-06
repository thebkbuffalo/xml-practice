class OrganizationSerializer < ActiveModel::Serializer
  attributes :id, :name, :ein
  has_many :filings
  has_many :addresses
end
