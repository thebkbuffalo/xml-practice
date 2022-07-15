class OrganizationSerializer < ActiveModel::Serializer
  attributes :id, :name, :ein, :is_filer, :is_receiver, :organization_awards
  has_many :filings
  has_many :addresses

  # added this to bring awards data associated with an org to the front end
  def organization_awards
    Award.where(receiver_id: object.id)
  end
end
