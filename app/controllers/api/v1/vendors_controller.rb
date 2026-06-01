module Api
  module V1
    class VendorsController < BaseController
      include Authenticatable

      # GET /api/v1/vendors/nearby
      def nearby
        result = NearbyVendorsService.call(
          latitude:    params[:latitude],
          longitude:   params[:longitude],
          radius_m:    radius_meters,
          category:    params[:category],
          min_rating:  params[:min_rating],
          open:        params[:open],
          page:        params[:page],
          per_page:    params[:per_page],
          cache_scope: current_user&.id
        )

        render_success(
          data: { vendors: serialize_collection(result.records, serializer: NearbyVendorSerializer) },
          meta: result.meta
        )
      end

      private

      # Accepts either `radius` (km, friendly) or `radius_m` (meters, precise).
      def radius_meters
        return params[:radius_m] if params[:radius_m].present?
        return nil               if params[:radius].blank?

        (params[:radius].to_f * 1_000).to_i
      end
    end
  end
end
