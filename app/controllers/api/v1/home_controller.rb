module Api
  module V1
    class HomeController < BaseController
      include Authenticatable

      def feed
        featured  = Design.available.featured.includes(:decorator, :category).limit(10)
        trending  = Design.available.trending.includes(:decorator, :category).limit(10)
        nearby    = Decorator.active.nearby(params[:city] || current_user.city).order(rating_avg: :desc).limit(10)
        categories = Category.active.ordered

        render_success(data: {
          categories: serialize_collection(categories, serializer: CategorySerializer),
          featured_designs:  serialize_collection(featured,  serializer: DesignSummarySerializer),
          trending_designs:  serialize_collection(trending,  serializer: DesignSummarySerializer),
          nearby_vendors:    serialize_collection(nearby,    serializer: DecoratorSerializer)
        })
      end
    end
  end
end
