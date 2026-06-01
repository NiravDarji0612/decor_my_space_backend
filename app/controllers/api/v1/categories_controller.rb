module Api
  module V1
    class CategoriesController < BaseController
      def index
        categories = Category.active.ordered
        render_success(data: { categories: serialize_collection(categories, serializer: CategorySerializer) })
      end

      def show
        category = Category.active.find_by!(slug: params[:slug])
        render_success(data: { category: serialize(category, serializer: CategorySerializer) })
      end
    end
  end
end
