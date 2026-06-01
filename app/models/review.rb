class Review < ApplicationRecord
  belongs_to :booking
  belongs_to :user
  belongs_to :decorator
  belongs_to :design

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :comment, length: { maximum: 500 }
  validates :booking_id, uniqueness: true

  after_commit :refresh_aggregates, on: %i[create update destroy]

  private

  def refresh_aggregates
    decorator.recompute_rating!
    design.recompute_rating!
  end
end
