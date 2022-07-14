class AwardSerializer < ActiveModel::Serializer
  attributes :id, :cash_amount, :non_cash_amount, :purpose, :irs_section, :filer_org_name
  belongs_to :receiver

  def filer_org_name
    object.filing.organization.name
  end
end
