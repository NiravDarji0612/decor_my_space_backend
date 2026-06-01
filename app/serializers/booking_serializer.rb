class BookingSerializer < ActiveModel::Serializer
  attributes :id, :booking_reference, :status,
             :event_type, :event_date, :time_slot, :expected_guests,
             :venue_name, :venue_address_line1, :venue_address_line2,
             :contact_full_name, :contact_phone, :contact_email,
             :special_instructions,
             :subtotal_rupees, :gst_rupees, :total_rupees,
             :advance_paid_rupees, :balance_rupees,
             :payment_method, :payment_status,
             :placed_on, :cancelled_at, :cancellation_reason

  belongs_to :design,    serializer: DesignSummarySerializer
  belongs_to :decorator, serializer: DecoratorSerializer
  has_many   :add_ons,   serializer: AddOnSerializer

  def subtotal_rupees;     object.subtotal_cents / 100; end
  def gst_rupees;          object.gst_cents / 100; end
  def total_rupees;        object.total_cents / 100; end
  def advance_paid_rupees; object.advance_paid_cents / 100; end
  def balance_rupees;      object.balance_cents / 100; end

  def event_date
    object.event_date&.iso8601
  end

  def placed_on
    object.placed_on&.iso8601
  end

  def cancelled_at
    object.cancelled_at&.iso8601
  end
end
