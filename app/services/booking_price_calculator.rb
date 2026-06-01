class BookingPriceCalculator
  GST_RATE     = Booking::GST_RATE
  ADVANCE_RATE = Booking::ADVANCE_RATE

  Result = Struct.new(:subtotal_cents, :gst_cents, :total_cents, :advance_cents, :add_on_lines, keyword_init: true)

  def self.call(design:, add_ons: [])
    new(design, add_ons).call
  end

  def initialize(design, add_ons)
    @design  = design
    @add_ons = Array(add_ons)
  end

  def call
    add_on_lines = @add_ons.map { |a| { id: a.id, price_cents: a.price_cents } }
    add_on_total = add_on_lines.sum { |l| l[:price_cents] }
    subtotal = @design.price_cents + add_on_total
    gst      = (subtotal * GST_RATE).round
    total    = subtotal + gst
    advance  = (total * ADVANCE_RATE).round

    Result.new(
      subtotal_cents: subtotal,
      gst_cents:      gst,
      total_cents:    total,
      advance_cents:  advance,
      add_on_lines:   add_on_lines
    )
  end
end
