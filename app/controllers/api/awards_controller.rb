module Api
  class AwardsController < Api::BaseController
    before_action :ensure_json_request

    def index
      @awards = Award

      organization_id = params[:organization_id]
      if organization_id.present?
        @awards = @awards.joins(:filing).where("filings.organization_id": organization_id)
      end

      filing_id = params[:filing_id]
      if filing_id.present?
        @awards = @awards.where(filing_id: filing_id)
      end

      respond_to do |format|
        format.json {
          render json: {
            awards: @awards.order(
              pagination_params[:order_by] => pagination_params[:sort_dir]
            ).page(
              pagination_params[:page].to_i
            ).per(
              pagination_params[:per_page]
            ),
            total_count: @awards.count
          }
        }
      end
    end

    def show
      @award = Award.find(params[:id])

      respond_to do |format|
        format.json { render json: @award }
      end
    end

    def default_order_by
      "cash_amount"
    end
  end
end
