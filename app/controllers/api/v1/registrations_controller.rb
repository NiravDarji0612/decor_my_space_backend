module Api
  module V1
    class RegistrationsController < BaseController
      def create
        user = User.new(registration_params)

        if user.save
          tokens = JwtService.generate_tokens(user)
          render_success(
            data: {
              user: serialize(user),
              tokens: tokens
            },
            message: "Account created successfully",
            status: :created
          )
        else
          render_error(
            message: "Registration failed",
            errors: user.errors.full_messages,
            status: :unprocessable_entity
          )
        end
      end

      private

      def registration_params
        params.require(:user).permit(
          :full_name,
          :email,
          :phone,
          :password,
          :password_confirmation,
          :account_type,
          :accepted_terms
        )
      end
    end
  end
end
