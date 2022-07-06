module Api
  class BaseController < ApplicationController
    before_action :ensure_json_request

    protected

    def pagination_params
      @pagination_params ||= begin
        order_by = page_params[:order_by] || default_order_by
        sort_dir = page_params[:sort_dir] || default_sort_dir
        sort_dir = ["asc", "desc"].include?(sort_dir) ? sort_dir : "asc"
        per_page = [(page_params[:per_page] || 30).to_i.abs, 50].min
        page = page_params[:page].to_i.abs
        {
          order_by: order_by,
          sort_dir: sort_dir,
          per_page: per_page,
          page: page
        }
      end
    end

    def default_order_by
      raise "must be implemented by the inheritor"
    end

    def default_sort_dir
      "asc"
    end

    def page_params
      params.permit(:order_by, :sort_dir, :per_page, :page)
    end
  end
end
