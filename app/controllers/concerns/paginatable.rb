module Paginatable
  extend ActiveSupport::Concern

  DEFAULT_PER = 20
  MAX_PER     = 100

  private

  def paginate(scope)
    page     = [params[:page].to_i, 1].max
    per_page = (params[:per_page].presence || DEFAULT_PER).to_i.clamp(1, MAX_PER)
    total    = scope.except(:order).count
    records  = scope.limit(per_page).offset((page - 1) * per_page)
    meta     = {
      page:        page,
      per_page:    per_page,
      total:       total,
      total_pages: (total.to_f / per_page).ceil
    }
    [records, meta]
  end
end
