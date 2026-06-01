module Api
  module V1
    class ProfilesController < BaseController
      include Authenticatable

      def show
        authorize current_user
        render_success(data: { user: serialize(current_user) })
      end

      def update
        authorize current_user, :update?
        current_user.update!(profile_params)
        render_success(data: { user: serialize(current_user) }, message: "Profile updated")
      end

      def change_password
        unless current_user.authenticate(params.dig(:password, :current_password))
          return render_error(message: "Current password is incorrect", status: :unprocessable_entity)
        end

        if current_user.update(
          password:              params.dig(:password, :new_password),
          password_confirmation: params.dig(:password, :new_password_confirmation)
        )
          render_success(message: "Password changed successfully")
        else
          render_error(message: "Password change failed", errors: current_user.errors.full_messages)
        end
      end

      def request_email_change
        new_email = params.dig(:email, :new_email).to_s.strip.downcase
        raise ValidationError.new("Invalid email") unless new_email.match?(URI::MailTo::EMAIL_REGEXP)
        raise ValidationError.new("Email already in use") if User.where("LOWER(email) = ?", new_email).where.not(id: current_user.id).exists?

        OtpService.issue(user: current_user, purpose: :email_change, destination: new_email, channel: :email)
        render_success(message: "OTP sent to #{new_email}")
      end

      def confirm_email_change
        OtpService.verify!(user: current_user, purpose: :email_change, code: params[:code])
        new_email = params[:new_email].to_s.strip.downcase
        current_user.update!(email: new_email, email_verified_at: Time.current)
        render_success(data: { user: serialize(current_user) }, message: "Email updated")
      end

      def request_phone_change
        new_phone = params.dig(:phone, :new_phone).to_s.strip
        raise ValidationError.new("Invalid phone") unless new_phone.match?(/\A\+?[\d\s().\-]{7,}\z/)
        raise ValidationError.new("Phone already in use") if User.where(phone: new_phone).where.not(id: current_user.id).exists?

        OtpService.issue(user: current_user, purpose: :phone_change, destination: new_phone, channel: :sms)
        render_success(message: "OTP sent to #{new_phone}")
      end

      def confirm_phone_change
        OtpService.verify!(user: current_user, purpose: :phone_change, code: params[:code])
        new_phone = params[:new_phone].to_s.strip
        current_user.update!(phone: new_phone, phone_verified_at: Time.current)
        render_success(data: { user: serialize(current_user) }, message: "Phone updated")
      end

      def destroy
        authorize current_user, :destroy?
        current_user.soft_delete!
        render_success(message: "Account deleted")
      end

      private

      def profile_params
        params.require(:user).permit(:full_name, :username, :city, :bio, :avatar_url)
      end
    end
  end
end
