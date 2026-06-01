module Api
  module V1
    class UserLocationsController < BaseController
      include Authenticatable

      # POST /api/v1/users/:id/location
      def create
        target = User.active.find(params[:id])
        authorize target, :update?, policy_class: UserPolicy

        UserLocationService.call(
          user:       target,
          latitude:   location_params[:latitude],
          longitude:  location_params[:longitude],
          accuracy_m: location_params[:accuracy_m],
          source:     location_params[:source]
        )

        render_success(message: "Location updated successfully")
      end

      private

      def location_params
        params.permit(:latitude, :longitude, :accuracy_m, :source,
                      location: %i[latitude longitude accuracy_m source])
              .then { |p| p[:location].presence || p }
      end
    end
  end
end
