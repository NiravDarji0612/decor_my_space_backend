module Api
  module V1
    class ProfilesController < BaseController
      include Authenticatable

      def show
        authorize current_user
        render_success(data: { user: serialize(current_user) })
      end
    end
  end
end
