class OtpService
  TTL = OtpVerification::TTL

  def self.issue(user:, purpose:, destination:, channel:)
    code   = format("%0#{OtpVerification::CODE_LENGTH}d", SecureRandom.random_number(10**OtpVerification::CODE_LENGTH))
    digest = BCrypt::Password.create(code)

    # Invalidate older active OTPs for the same purpose
    user.otp_verifications
        .where(purpose: OtpVerification.purposes[purpose])
        .where(consumed_at: nil)
        .update_all(consumed_at: Time.current)

    otp = user.otp_verifications.create!(
      purpose:     purpose,
      channel:     channel,
      destination: destination,
      code_digest: digest,
      expires_at:  TTL.from_now
    )

    OtpDeliveryJob.perform_later(otp_id: otp.id, code: code)
    otp
  end

  def self.verify!(user:, purpose:, code:)
    otp = user.otp_verifications
              .where(purpose: OtpVerification.purposes[purpose])
              .order(created_at: :desc).first

    raise ValidationError.new("No OTP found. Please request a new code.") unless otp
    raise ValidationError.new("OTP expired. Please request a new code.")  if otp.expired? || otp.consumed?
    raise ValidationError.new("Too many invalid attempts. Request a new code.") if otp.attempts >= OtpVerification::MAX_ATTEMPTS

    unless otp.matches?(code)
      otp.increment!(:attempts)
      raise ValidationError.new("Invalid OTP code")
    end

    otp.update!(consumed_at: Time.current)
    otp
  end
end
