module Api
  module V1
    class DesignsController < BaseController
      def index
        scope = Design.available.includes(:decorator, :category)
        scope = scope.in_category_slug(params[:slug]) if params[:slug].present?
        scope = scope.search(params[:q])
        scope = scope.sort_by_param(params[:sort])

        designs, meta = paginate(scope)
        render_success(
          data: { designs: serialize_collection(designs, serializer: DesignSummarySerializer) },
          meta: meta
        )
      end

      def show
        design = Design.includes(:decorator, :category, :images, :inclusions).find(params[:id])
        render_success(data: { design: serialize(design, serializer: DesignSerializer) })
      end
    end
  end
end
