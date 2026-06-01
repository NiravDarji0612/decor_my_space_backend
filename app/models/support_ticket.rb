class SupportTicket < ApplicationRecord
  enum :status, { open: 0, in_progress: 1, resolved: 2, closed: 3 }

  belongs_to :user, optional: true

  validates :category, :subject, :message, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
end
