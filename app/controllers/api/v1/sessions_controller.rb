module Api
  module V1
    class SessionsController < BaseController
      include Authenticatable

      skip_before_action :authenticate_user!, only: :create

      def create
        user = User.find_by(email: login_params[:email]&.strip&.downcase)

        if user&.authenticate(login_params[:password])
          tokens = JwtService.generate_tokens(user)
          render_success(
            data: {
              user: serialize(user),
              tokens: tokens
            },
            message: "Logged in successfully"
          )
        else
          render_error(
            message: "Invalid email or password",
            status: :unauthorized
          )
        end
      end

      def refresh
        token = extract_token
        payload = JwtService.decode(token)

        unless payload[:type] == "refresh"
          return render_error(message: "Invalid token type. Use refresh token.", status: :unauthorized)
        end

        user = User.find_by(id: payload[:user_id])
        unless user
          return render_error(message: "User not found", status: :unauthorized)
        end

        tokens = JwtService.generate_tokens(user)
        render_success(
          data: { tokens: tokens },
          message: "Token refreshed successfully"
        )
      rescue AuthenticationError => e
        render_error(message: e.message, status: :unauthorized)
      end

      private

      def login_params
        params.require(:session).permit(:email, :password)
      end
    end
  end
end
