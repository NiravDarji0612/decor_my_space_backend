module Api
  module V1
    class PaymentMethodsController < BaseController
      include Authenticatable

      def index
        methods = policy_scope(PaymentMethod).default_first
        render_success(data: { payment_methods: serialize_collection(methods, serializer: PaymentMethodSerializer) })
      end

      def create
        pm = current_user.payment_methods.new(payment_method_params)
        authorize pm
        pm.save!
        pm.make_default! if first_method?
        render_success(
          data: { payment_method: serialize(pm.reload, serializer: PaymentMethodSerializer) },
          status: :created, message: "Payment method added"
        )
      end

      def destroy
        pm = current_user.payment_methods.find(params[:id])
        authorize pm
        pm.destroy!
        render_success(message: "Payment method removed")
      end

      def default
        pm = current_user.payment_methods.find(params[:id])
        authorize pm, :default?
        pm.make_default!
        render_success(data: { payment_method: serialize(pm.reload, serializer: PaymentMethodSerializer) }, message: "Default payment method updated")
      end

      private

      def payment_method_params
        params.require(:payment_method).permit(
          :kind, :title, :subtitle, :last4, :provider_token, :expires_on, :is_default
        )
      end

      def first_method?
        current_user.payment_methods.count == 1
      end
    end
  end
end
