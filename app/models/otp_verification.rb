class OtpVerification < ApplicationRecord
  enum :channel, { email: 0, sms: 1 }
  enum :purpose, {
    email_change: 0,
    phone_change: 1,
    verify_email: 2,
    verify_phone: 3,
    forgot_password: 4
  }, prefix: true

  MAX_ATTEMPTS = 5
  CODE_LENGTH  = 6
  TTL          = 10.minutes

  belongs_to :user

  validates :destination, :code_digest, :expires_at, presence: true

  scope :active, -> { where(consumed_at: nil).where("expires_at > ?", Time.current) }

  def consumed?
    consumed_at.present?
  end

  def expired?
    expires_at <= Time.current
  end

  def matches?(code)
    BCrypt::Password.new(code_digest).is_password?(code.to_s)
  rescue BCrypt::Errors::InvalidHash
    false
  end
end
