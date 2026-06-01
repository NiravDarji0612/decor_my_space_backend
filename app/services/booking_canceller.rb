class BookingCanceller
  def self.call(booking:, reason: nil)
    new(booking, reason).call
  end

  def initialize(booking, reason)
    @booking = booking
    @reason  = reason
  end

  def call
    raise ValidationError.new("Booking cannot be cancelled") unless @booking.cancellable?

    @booking.transaction do
      @booking.update!(
        status:              :cancelled,
        cancelled_at:        Time.current,
        cancellation_reason: @reason,
        payment_status:      @booking.payment_paid? ? :refunded : @booking.payment_status
      )
    end

    NotificationDispatchJob.perform_later(
      user_id: @booking.user_id,
      title:   "Booking cancelled",
      body:    "Your booking #{@booking.booking_reference} has been cancelled.",
      kind:    "booking",
      payload: { booking_id: @booking.id }
    )

    @booking
  end
end
