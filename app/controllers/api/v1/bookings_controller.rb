module Api
  module V1
    class BookingsController < BaseController
      include Authenticatable

      def index
        scope = policy_scope(Booking).includes(:design, :decorator, :add_ons).by_status(params[:status]).recent
        bookings, meta = paginate(scope)
        render_success(
          data: { bookings: serialize_collection(bookings, serializer: BookingSerializer) },
          meta: meta
        )
      end

      def show
        booking = policy_scope(Booking).includes(:design, :decorator, :add_ons, :review).find(params[:id])
        authorize booking
        render_success(data: { booking: serialize(booking, serializer: BookingSerializer) })
      end

      def create
        authorize Booking
        booking = BookingCreator.call(user: current_user, attributes: booking_params)
        render_success(
          data: { booking: serialize(booking, serializer: BookingSerializer) },
          message: "Booking confirmed",
          status:  :created
        )
      end

      def cancel
        booking = policy_scope(Booking).find(params[:id])
        authorize booking, :cancel?
        BookingCanceller.call(booking: booking, reason: params[:reason])
        render_success(
          data: { booking: serialize(booking.reload, serializer: BookingSerializer) },
          message: "Booking cancelled"
        )
      end

      private

      def booking_params
        params.require(:booking).permit(
          :design_id, :event_type, :event_date, :time_slot, :expected_guests,
          :venue_name, :venue_address_line1, :venue_address_line2,
          :contact_full_name, :contact_phone, :contact_email,
          :special_instructions, :payment_method,
          add_on_ids: []
        )
      end
    end
  end
end
