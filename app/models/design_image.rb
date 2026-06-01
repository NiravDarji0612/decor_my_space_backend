class DesignImage < ApplicationRecord
  belongs_to :design

  validates :url, presence: true
end
