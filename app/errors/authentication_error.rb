class AuthenticationError < StandardError
  def initialize(message = "Authentication failed")
    super
  end
end
