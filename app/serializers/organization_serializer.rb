class OrganizationSerializer < ActiveModel::Serializer
  attributes :id, :name, :ein, :is_filer, :is_receiver
  has_many :filings
  has_many :addresses
end
