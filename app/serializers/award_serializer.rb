class AwardSerializer < ActiveModel::Serializer
  attributes :id, :cash_amount, :non_cash_amount, :purpose, :irs_section, :filer_org_name
  belongs_to :receiver

  # added this to bring the filers org name to the front end
  def filer_org_name
    object.filing.organization.name
  end
end
