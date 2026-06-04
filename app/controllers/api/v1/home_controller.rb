module Api
  module V1
    class HomeController < BaseController
      include Authenticatable
      include LocationFilterable

      def feed
        featured  = Design.available.featured.includes(:decorator, :category).limit(10)
        trending  = Design.available.trending.includes(:decorator, :category).limit(10)
        nearby    = nearby_vendors_scope.limit(10)
        categories = Category.active.ordered

        render_success(data: {
          categories: serialize_collection(categories, serializer: CategorySerializer),
          featured_designs:  serialize_collection(featured,  serializer: DesignSummarySerializer),
          trending_designs:  serialize_collection(trending,  serializer: DesignSummarySerializer),
          nearby_vendors:    serialize_collection(nearby,    serializer: DecoratorSerializer)
        })
      end

      private

      def nearby_vendors_scope
        city = location_filtering_enabled? ? (params[:city] || current_user.city) : nil
        Decorator.active.nearby(city).order(rating_avg: :desc, review_count: :desc)
      end
    end
  end
end
