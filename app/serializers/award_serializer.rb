class AwardSerializer < ActiveModel::Serializer
  attributes :id, :cash_amount, :non_cash_amount, :purpose, :irs_section
  belongs_to :receiver
end
