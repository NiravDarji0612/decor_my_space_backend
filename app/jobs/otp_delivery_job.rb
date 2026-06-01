class OtpDeliveryJob < ApplicationJob
  queue_as :default

  def perform(otp_id:, code:)
    otp = OtpVerification.find_by(id: otp_id)
    return unless otp

    # TODO: integrate real email/SMS providers. For now we just log so dev can read it.
    Rails.logger.info("[OTP] purpose=#{otp.purpose} channel=#{otp.channel} dest=#{otp.destination} code=#{code}")
  end
end
