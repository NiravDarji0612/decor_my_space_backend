class Address < ApplicationRecord
  belongs_to :user

  validates :label, :recipient_name, :line1, :phone, presence: true
  validates :country, presence: true, length: { is: 2 }

  scope :default_first, -> { order(is_default: :desc, updated_at: :desc) }

  after_save :ensure_single_default

  def make_default!
    transaction do
      user.addresses.where.not(id: id).update_all(is_default: false)
      update!(is_default: true)
    end
  end

  private

  def ensure_single_default
    return unless saved_change_to_is_default? && is_default?

    user.addresses.where.not(id: id).update_all(is_default: false)
  end
end
