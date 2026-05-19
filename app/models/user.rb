class User < ApplicationRecord
  has_secure_password

  enum :account_type, { customer: 0, vendor: 1 }

  normalizes :email, with: ->(email) { email.strip.downcase }
  normalizes :phone, with: ->(phone) { phone.strip }
  normalizes :full_name, with: ->(name) { name.strip }

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
end
