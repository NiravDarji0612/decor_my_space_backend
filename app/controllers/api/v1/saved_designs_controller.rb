module Api
  module V1
    class SavedDesignsController < BaseController
      include Authenticatable

      def index
        scope = policy_scope(SavedDesign).includes(design: %i[decorator category]).order(created_at: :desc)
        records, meta = paginate(scope)
        render_success(
          data: { saved_designs: serialize_collection(records, serializer: SavedDesignSerializer) },
          meta: meta
        )
      end

      def create
        design = Design.available.find(params[:design_id])
        record = current_user.saved_designs.find_or_create_by!(design: design)
        render_success(
          data: { saved_design: serialize(record, serializer: SavedDesignSerializer) },
          message: "Design saved",
          status: :created
        )
      end

      def destroy
        record = current_user.saved_designs.find(params[:id])
        authorize record
        record.destroy!
        render_success(message: "Removed from saved designs")
      end
    end
  end
end
