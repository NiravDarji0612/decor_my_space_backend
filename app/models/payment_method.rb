class PaymentMethod < ApplicationRecord
  enum :kind, { card: 0, upi: 1, wallet: 2 }

  belongs_to :user

  validates :title, presence: true
  validates :last4, length: { is: 4 }, allow_blank: true

  scope :default_first, -> { order(is_default: :desc, updated_at: :desc) }

  after_save :ensure_single_default

  def make_default!
    transaction do
      user.payment_methods.where.not(id: id).update_all(is_default: false)
      update!(is_default: true)
    end
  end

  private

  def ensure_single_default
    return unless saved_change_to_is_default? && is_default?

    user.payment_methods.where.not(id: id).update_all(is_default: false)
  end
end
