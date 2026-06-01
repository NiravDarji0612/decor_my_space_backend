class BookingAddOn < ApplicationRecord
  belongs_to :booking
  belongs_to :add_on

  validates :add_on_id, uniqueness: { scope: :booking_id }
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }
end
