module Api
  module V1
    class AddressesController < BaseController
      include Authenticatable

      def index
        addresses = policy_scope(Address).default_first
        render_success(data: { addresses: serialize_collection(addresses, serializer: AddressSerializer) })
      end

      def show
        address = current_user.addresses.find(params[:id])
        authorize address
        render_success(data: { address: serialize(address, serializer: AddressSerializer) })
      end

      def create
        address = current_user.addresses.new(address_params)
        authorize address
        address.save!
        address.make_default! if first_address?
        render_success(
          data: { address: serialize(address.reload, serializer: AddressSerializer) },
          status: :created, message: "Address saved"
        )
      end

      def update
        address = current_user.addresses.find(params[:id])
        authorize address
        address.update!(address_params)
        render_success(data: { address: serialize(address.reload, serializer: AddressSerializer) }, message: "Address updated")
      end

      def destroy
        address = current_user.addresses.find(params[:id])
        authorize address
        address.destroy!
        render_success(message: "Address removed")
      end

      def default
        address = current_user.addresses.find(params[:id])
        authorize address, :default?
        address.make_default!
        render_success(data: { address: serialize(address.reload, serializer: AddressSerializer) }, message: "Default address updated")
      end

      private

      def address_params
        params.require(:address).permit(
          :label, :recipient_name, :line1, :line2, :city, :state,
          :postal_code, :country, :phone, :is_default
        )
      end

      def first_address?
        current_user.addresses.count == 1
      end
    end
  end
end
