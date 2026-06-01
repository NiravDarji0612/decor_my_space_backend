class User < ApplicationRecord
  include Geocodable

  has_secure_password

  enum :account_type, { customer: 0, vendor: 1 }

  has_one  :decorator,        dependent: :destroy
  has_one  :user_preference,  dependent: :destroy
  has_many :bookings,         dependent: :destroy
  has_many :reviews,          dependent: :destroy
  has_many :saved_designs,    dependent: :destroy
  has_many :favorite_designs, through: :saved_designs, source: :design
  has_many :addresses,        dependent: :destroy
  has_many :payment_methods,  dependent: :destroy
  has_many :notifications,    dependent: :destroy
  has_many :support_tickets,  dependent: :nullify
  has_many :otp_verifications, dependent: :destroy
  has_many :location_histories, class_name: "UserLocationHistory", dependent: :destroy

  normalizes :email,     with: ->(email) { email.strip.downcase }
  normalizes :phone,     with: ->(phone) { phone.strip }
  normalizes :full_name, with: ->(name)  { name.strip }

  validates :full_name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }
  validates :phone, presence: true,
                    uniqueness: true,
                    format: { with: /\A\+?[\d\s().\-]{7,}\z/, message: "must be a valid phone number" }
  validates :password, presence: true, length: { minimum: 8 }, on: :create
  validates :account_type, presence: true, inclusion: { in: account_types.keys }
  validates :accepted_terms, acceptance: { accept: true, message: "must be accepted" }
  validates :username, uniqueness: { case_sensitive: false }, allow_blank: true,
                       length: { in: 3..30 },
                       format: { with: /\A[a-zA-Z0-9_.]+\z/, message: "only letters, numbers, _ and ." }

  after_create :build_default_preferences

  scope :active, -> { where(deleted_at: nil) }

  def soft_delete!
    update!(deleted_at: Time.current)
  end

  def preferences
    user_preference || build_user_preference.tap(&:save!)
  end

  private

  def build_default_preferences
    create_user_preference! unless user_preference
  end
end
