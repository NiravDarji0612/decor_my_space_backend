module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end

  private

  def authenticate_user!
    token = extract_token
    raise AuthenticationError, "Missing authorization token" if token.blank?

    payload = JwtService.decode(token)
    raise AuthenticationError, "Invalid token type" if payload[:type] == "refresh"

    @current_user = User.active.find_by(id: payload[:user_id])
    raise AuthenticationError, "User not found" unless @current_user
  end

  def current_user
    @current_user
  end

  def extract_token
    header = request.headers["Authorization"]
    header&.split(" ")&.last
  end
end
