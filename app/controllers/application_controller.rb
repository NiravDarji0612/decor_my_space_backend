class ApplicationController < ActionController::API
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError,           with: :handle_unauthorized
  rescue_from ActiveRecord::RecordNotFound,         with: :handle_not_found
  rescue_from NotFoundError,                        with: :handle_not_found
  rescue_from ActiveRecord::RecordInvalid,          with: :handle_record_invalid
  rescue_from ActionController::ParameterMissing,   with: :handle_bad_request
  rescue_from ValidationError,                      with: :handle_validation_error
  rescue_from AuthenticationError,                  with: :handle_authentication_error

  private

  def handle_unauthorized
    render json: { success: false, error: "You are not authorized to perform this action" }, status: :forbidden
  end

  def handle_not_found(error)
    render json: { success: false, error: error.message.presence || "Resource not found" }, status: :not_found
  end

  def handle_record_invalid(error)
    render json: {
      success: false,
      error: "Validation failed",
      errors: error.record.errors.full_messages
    }, status: :unprocessable_entity
  end

  def handle_bad_request(error)
    render json: { success: false, error: error.message }, status: :bad_request
  end

  def handle_validation_error(error)
    render json: { success: false, error: error.message, errors: error.errors }, status: :unprocessable_entity
  end

  def handle_authentication_error(error)
    render json: { success: false, error: error.message }, status: :unauthorized
  end
end
