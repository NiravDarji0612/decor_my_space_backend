module Api
  module V1
    class CategoryDesignsController < BaseController
      def index
        category = Category.active.find_by!(slug: params[:slug])
        scope    = category.designs.available.includes(:decorator, :category).sort_by_param(params[:sort])
        designs, meta = paginate(scope)
        render_success(
          data: {
            category: serialize(category, serializer: CategorySerializer),
            designs:  serialize_collection(designs, serializer: DesignSummarySerializer)
          },
          meta: meta
        )
      end
    end
  end
end
