module Api
  class HomeController < Api::BaseController
    before_action :ensure_json_request

    def index
      @organizations = Organization.last(5)
      filings = Filing.last(5)
      @robust_filings = filings.map do |f|
        {
          id: f.id,
          tax_period: f.tax_period,
          awards_count: f.awards.count,
          total_amount_given: f.awards.sum(:cash_amount) + f.awards.sum(:non_cash_amount),
          org_name: f.organization.name
        }
      end
      awards = Award.last(5)
      @robust_awards = awards.map do |award|
        {
          id: award.id,
          receiver_name: award.receiver.name,
          cash_amount: award.cash_amount,
          purpose: award.purpose
        }
      end
      payload = {
        organizations: @organizations,
        filings: @robust_filings,
        awards: @robust_awards
      }
      respond_to do |format|
        format.json { render json: payload }
      end
    end
  end
end