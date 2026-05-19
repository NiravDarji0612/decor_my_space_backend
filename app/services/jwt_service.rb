class JwtService
  SECRET_KEY = Rails.application.credentials.secret_key_base
  ALGORITHM = "HS256"
  ACCESS_TOKEN_EXPIRY = 24.hours
  REFRESH_TOKEN_EXPIRY = 30.days

  class << self
    def encode(payload, expiry: ACCESS_TOKEN_EXPIRY)
      payload = payload.dup
      payload[:exp] = expiry.from_now.to_i
      payload[:iat] = Time.current.to_i
      JWT.encode(payload, SECRET_KEY, ALGORITHM)
    end

    def decode(token)
      decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: ALGORITHM })
      HashWithIndifferentAccess.new(decoded.first)
    rescue JWT::ExpiredSignature
      raise AuthenticationError, "Token has expired"
    rescue JWT::DecodeError
      raise AuthenticationError, "Invalid token"
    end

    def generate_tokens(user)
      access_token = encode({ user_id: user.id }, expiry: ACCESS_TOKEN_EXPIRY)
      refresh_token = encode({ user_id: user.id, type: "refresh" }, expiry: REFRESH_TOKEN_EXPIRY)
      {
        access_token: access_token,
        refresh_token: refresh_token,
        expires_in: ACCESS_TOKEN_EXPIRY.to_i
      }
    end
  end
end
