module Api
  module V1
    class DecoratorsController < BaseController
      include LocationFilterable

      def index
        city  = location_filtering_enabled? ? params[:city] : nil
        scope = Decorator.active.nearby(city)
        scope = scope.where("LOWER(name) LIKE ?", "%#{params[:q].downcase}%") if params[:q].present?
        scope = scope.order(rating_avg: :desc)
        decorators, meta = paginate(scope)
        render_success(
          data: { decorators: serialize_collection(decorators, serializer: DecoratorSerializer) },
          meta: meta
        )
      end

      def show
        decorator = Decorator.active.includes(designs: %i[category]).find(params[:id])
        render_success(data: { decorator: serialize(decorator, serializer: DecoratorDetailSerializer) })
      end
    end
  end
end
