module Api
  class AddressesController < Api::BaseController
    before_action :ensure_json_request

    def index
      @addresses = Address.order(
        pagination_params[:order_by] => pagination_params[:sort_dir]
      ).page(
        pagination_params[:page].to_i
      ).per(
        pagination_params[:per_page]
      )

      organization_id = params[:organization_id]
      if organization_id.present?
        @addresses = @addresses.where(organization_id: organization_id)
      end

      respond_to do |format|
        format.json { render json: @addresses }
      end
    end

    def show
      @address = Address.find(params[:id])

      respond_to do |format|
        format.json { render json: @address }
      end
    end

    def default_order_by
      "name"
    end
  end
end
