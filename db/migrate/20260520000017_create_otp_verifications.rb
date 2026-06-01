class CreateOtpVerifications < ActiveRecord::Migration[8.0]
  def change
    create_table :otp_verifications do |t|
      t.references :user, null: false, foreign_key: true
      t.integer  :channel,  null: false, default: 0 # email | sms
      t.integer  :purpose,  null: false, default: 0 # email_change | phone_change | verify_email | verify_phone | forgot_password
      t.string   :destination, null: false
      t.string   :code_digest, null: false
      t.integer  :attempts,    null: false, default: 0
      t.datetime :expires_at,  null: false
      t.datetime :consumed_at
      t.timestamps
    end

    add_index :otp_verifications, %i[user_id purpose]
  end
end
