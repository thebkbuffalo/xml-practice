class FilingSerializer < ActiveModel::Serializer
  attributes :id, :tax_period, :xml_url, :awards_count, :total_amount_given
  belongs_to :organization

  def awards_count
    object.awards.count
  end

  def total_amount_given
    object.awards.sum(:cash_amount) + object.awards.sum(:non_cash_amount)
  end
end
