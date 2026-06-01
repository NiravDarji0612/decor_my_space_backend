class Booking < ApplicationRecord
  GST_RATE       = 0.18
  ADVANCE_RATE   = 0.30

  enum :status,         { upcoming: 0, completed: 1, cancelled: 2 }
  enum :payment_method, { card: 0, upi: 1, netbanking: 2 }, prefix: :pay
  enum :payment_status, { pending: 0, paid: 1, refunded: 2 }, prefix: :payment

  belongs_to :user
  belongs_to :design
  belongs_to :decorator

  has_many :booking_add_ons, dependent: :destroy
  has_many :add_ons, through: :booking_add_ons
  has_one  :review, dependent: :destroy

  validates :booking_reference, presence: true, uniqueness: true
  validates :event_type, :event_date, :time_slot, presence: true
  validates :venue_name, :venue_address_line1,
            :contact_full_name, :contact_phone, :contact_email, presence: true
  validates :contact_email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :expected_guests, numericality: { greater_than_or_equal_to: 0 }
  validates :total_cents, numericality: { greater_than_or_equal_to: 0 }

  scope :for_user, ->(user) { where(user_id: user.id) }
  scope :by_status, ->(s) { s.present? ? where(status: s) : all }
  scope :recent,    -> { order(placed_on: :desc) }

  def balance_cents
    total_cents - advance_paid_cents
  end

  def cancellable?
    upcoming? && event_date >= Date.current
  end
end
