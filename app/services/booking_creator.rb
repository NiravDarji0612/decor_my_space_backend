class BookingCreator
  def self.call(user:, attributes:)
    new(user, attributes).call
  end

  def initialize(user, attributes)
    @user  = user
    @attrs = attributes.to_h.symbolize_keys
  end

  def call
    design = Design.available.find_by(id: @attrs[:design_id])
    raise NotFoundError, "Design not found or unavailable" unless design

    add_ons = AddOn.active.where(id: Array(@attrs[:add_on_ids]))
    pricing = BookingPriceCalculator.call(design: design, add_ons: add_ons)

    booking = nil
    Booking.transaction do
      booking = Booking.create!(
        user:       @user,
        design:     design,
        decorator:  design.decorator,
        status:     :upcoming,
        booking_reference: generate_reference,
        event_type:        @attrs[:event_type],
        event_date:        @attrs[:event_date],
        time_slot:         @attrs[:time_slot],
        expected_guests:   @attrs[:expected_guests].to_i,
        venue_name:           @attrs[:venue_name],
        venue_address_line1:  @attrs[:venue_address_line1],
        venue_address_line2:  @attrs[:venue_address_line2],
        contact_full_name:    @attrs[:contact_full_name],
        contact_phone:        @attrs[:contact_phone],
        contact_email:        @attrs[:contact_email],
        special_instructions: @attrs[:special_instructions],
        subtotal_cents:     pricing.subtotal_cents,
        gst_cents:          pricing.gst_cents,
        total_cents:        pricing.total_cents,
        advance_paid_cents: pricing.advance_cents,
        payment_method:     @attrs[:payment_method].presence || "upi",
        payment_status:     :paid, # MVP: assume online payment captured client-side
        placed_on:          Time.current
      )

      pricing.add_on_lines.each do |line|
        booking.booking_add_ons.create!(add_on_id: line[:id], price_cents: line[:price_cents])
      end
    end

    NotificationDispatchJob.perform_later(
      user_id: @user.id,
      title:   "Booking confirmed",
      body:    "Your booking #{booking.booking_reference} is confirmed for #{booking.event_date}.",
      kind:    "booking",
      payload: { booking_id: booking.id }
    )

    booking
  end

  private

  def generate_reference
    loop do
      ref = "DMS-#{SecureRandom.alphanumeric(8).upcase}"
      break ref unless Booking.exists?(booking_reference: ref)
    end
  end
end
