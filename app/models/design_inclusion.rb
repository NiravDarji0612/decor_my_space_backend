class DesignInclusion < ApplicationRecord
  belongs_to :design

  validates :label, presence: true
end
