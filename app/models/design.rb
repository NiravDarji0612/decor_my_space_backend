class Design < ApplicationRecord
  belongs_to :decorator
  belongs_to :category

  has_many :images,     -> { order(:position) }, class_name: "DesignImage", dependent: :destroy, inverse_of: :design
  has_many :inclusions, -> { order(:position) }, class_name: "DesignInclusion", dependent: :destroy, inverse_of: :design
  has_many :bookings,      dependent: :restrict_with_error
  has_many :reviews,       dependent: :nullify
  has_many :saved_designs, dependent: :destroy

  accepts_nested_attributes_for :images,     allow_destroy: true
  accepts_nested_attributes_for :inclusions, allow_destroy: true

  validates :title, presence: true, length: { maximum: 160 }
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :currency, presence: true, length: { is: 3 }

  scope :available, -> { where(available: true) }
  scope :featured,  -> { where(featured: true) }
  scope :trending,  -> { where(trending: true) }
  scope :in_category_slug, ->(slug) { joins(:category).where(categories: { slug: slug }) }
  scope :search, ->(q) {
    q.present? ? where("LOWER(title) LIKE ?", "%#{q.downcase}%") : all
  }
  scope :sort_by_param, ->(key) {
    case key.to_s
    when "price_asc"  then order(price_cents: :asc)
    when "price_desc" then order(price_cents: :desc)
    when "rating"     then order(rating_avg: :desc)
    else order(saved_count: :desc, rating_avg: :desc) # popular
    end
  }

  def price_rupees
    price_cents / 100
  end

  def recompute_rating!
    stats = reviews.pick(Arel.sql("AVG(rating)"), Arel.sql("COUNT(*)"))
    update!(rating_avg: (stats[0] || 0).to_f.round(2), review_count: stats[1].to_i)
  end
end
