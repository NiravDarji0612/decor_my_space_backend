class AddOn < ApplicationRecord
  self.table_name = "add_ons"

  has_many :booking_add_ons, dependent: :restrict_with_error

  validates :key,   presence: true, uniqueness: true
  validates :label, presence: true
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }
end
