class AddressSerializer < ActiveModel::Serializer
  attributes :id, :address, :address2, :city, :state, :zip_code, :country
  belongs_to :organization
end
