class Notification < ApplicationRecord
  enum :kind, { system: 0, booking: 1, promotion: 2, payment: 3 }

  belongs_to :user

  validates :title, presence: true

  scope :unread, -> { where(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  def mark_read!
    update!(read_at: Time.current) if read_at.nil?
  end

  def unread?
    read_at.nil?
  end
end
