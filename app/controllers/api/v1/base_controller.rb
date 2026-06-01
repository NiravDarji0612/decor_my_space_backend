module Api
  module V1
    class BaseController < ApplicationController
      include Paginatable

      private

      def render_success(data: nil, message: nil, status: :ok, meta: nil)
        body = { success: true }
        body[:message] = message if message
        body[:data]    = data    if data
        body[:meta]    = meta    if meta
        render json: body, status: status
      end

      def render_error(message:, errors: nil, status: :unprocessable_entity)
        body = { success: false, error: message }
        body[:errors] = errors if errors
        render json: body, status: status
      end

      def serialize(resource, serializer: nil)
        opts = {}
        opts[:serializer] = serializer if serializer
        ActiveModelSerializers::SerializableResource.new(resource, opts).as_json
      end

      def serialize_collection(collection, serializer:)
        ActiveModelSerializers::SerializableResource.new(
          collection, each_serializer: serializer
        ).as_json
      end
    end
  end
end
