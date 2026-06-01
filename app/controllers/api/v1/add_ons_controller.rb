module Api
  module V1
    class AddOnsController < BaseController
      def index
        add_ons = AddOn.active.order(:label)
        render_success(data: { add_ons: serialize_collection(add_ons, serializer: AddOnSerializer) })
      end
    end
  end
end
