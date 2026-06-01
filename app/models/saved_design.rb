class SavedDesign < ApplicationRecord
  belongs_to :user
  belongs_to :design, counter_cache: :saved_count

  validates :design_id, uniqueness: { scope: :user_id }
end
