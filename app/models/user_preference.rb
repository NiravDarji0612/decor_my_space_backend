class UserPreference < ApplicationRecord
  belongs_to :user

  validates :locale,   inclusion: { in: %w[en ar hi] }
  validates :currency, inclusion: { in: %w[INR USD EUR AED] }
end
