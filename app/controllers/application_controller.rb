class ApplicationController < ActionController::Base
  def ensure_json_request
    return if request.format == :json
    head :not_acceptable
  end
end
