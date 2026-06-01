module Api
  module V1
    class PreferencesController < BaseController
      include Authenticatable

      def show
        render_success(data: { preferences: serialize(current_user.preferences, serializer: UserPreferenceSerializer) })
      end

      def update
        prefs = current_user.preferences
        prefs.update!(preference_params)
        render_success(
          data: { preferences: serialize(prefs, serializer: UserPreferenceSerializer) },
          message: "Preferences updated"
        )
      end

      private

      def preference_params
        params.require(:preferences).permit(
          :locale, :currency, :dark_mode, :location_services,
          :notify_bookings, :notify_promotions, :notify_system
        )
      end
    end
  end
end
