class Category < ApplicationRecord
  has_many :designs, dependent: :restrict_with_error

  validates :slug,  presence: true, uniqueness: true, format: { with: /\A[a-z0-9\-]+\z/ }
  validates :title, presence: true

  scope :active,   -> { where(active: true) }
  scope :ordered,  -> { order(:position, :title) }

  def design_count
    designs.where(available: true).count
  end
end
