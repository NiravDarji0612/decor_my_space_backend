class ApplicationController < ActionController::API
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :handle_unauthorized

  private

  def handle_unauthorized
    render json: { success: false, error: "You are not authorized to perform this action" }, status: :forbidden
  end
end
