# Returns vendors (Decorators) within a radius of the given coordinates,
# ordered by ascending distance. PostGIS ST_DWithin + ST_Distance are used
# when available, with a pure-SQL Haversine fallback otherwise.
#
# When geo_enabled: false (e.g. the `show_records_based_on_location` feature
# flag is OFF), latitude/longitude/radius are ignored and vendors are returned
# globally, ordered by rating then review count.
#
# Results are cached briefly in Rails.cache keyed on coarse coordinates
# (~111 m resolution) + filters, so map pans within the same neighbourhood
# don't re-query Postgres.
class NearbyVendorsService
  DEFAULT_RADIUS_M = 5_000     # 5 km
  MAX_RADIUS_M     = 50_000    # 50 km hard cap
  DEFAULT_PER_PAGE = 20
  MAX_PER_PAGE     = 100
  CACHE_TTL        = 60.seconds

  Result = Struct.new(:records, :meta, keyword_init: true)

  def self.call(...)
    new(...).call
  end

  def initialize(latitude:, longitude:, radius_m: nil, category: nil,
                 min_rating: nil, open: nil, page: 1, per_page: DEFAULT_PER_PAGE,
                 cache_scope: nil, geo_enabled: true)
    @geo_enabled = geo_enabled
    @latitude   = coerce_float(latitude)
    @longitude  = coerce_float(longitude)
    @radius_m   = (coerce_float(radius_m) || DEFAULT_RADIUS_M).clamp(1, MAX_RADIUS_M).to_i
    @category   = category.presence
    @min_rating = coerce_float(min_rating)
    @open       = coerce_bool(open)
    @page       = [page.to_i, 1].max
    @per_page   = (per_page.presence || DEFAULT_PER_PAGE).to_i.clamp(1, MAX_PER_PAGE)
    @cache_scope = cache_scope # e.g. current_user.id, or nil to skip caching
  end

  def call
    validate_inputs!

    Rails.cache.fetch(cache_key, expires_in: CACHE_TTL) { compute }
  end

  private

  def compute
    @geo_enabled ? compute_geo : compute_global
  end

  def compute_geo
    scope = Decorator.active
                     .within_radius(@latitude, @longitude, @radius_m)
                     .with_distance_from(@latitude, @longitude)
                     .with_category(@category)
                     .with_min_rating(@min_rating)
    scope = scope.where(open: @open) unless @open.nil?

    total   = scope.except(:select, :order).count
    records = scope.limit(@per_page).offset((@page - 1) * @per_page).to_a

    Result.new(
      records: records,
      meta: meta_for(total, engine: Decorator.postgis_geom? ? "postgis" : "haversine")
    )
  end

  def compute_global
    scope = Decorator.active
                     .with_category(@category)
                     .with_min_rating(@min_rating)
                     .order(rating_avg: :desc, review_count: :desc)
    scope = scope.where(open: @open) unless @open.nil?

    total   = scope.except(:order).count
    records = scope.limit(@per_page).offset((@page - 1) * @per_page).to_a

    Result.new(
      records: records,
      meta: meta_for(total, engine: "global")
    )
  end

  def meta_for(total, engine:)
    {
      page:        @page,
      per_page:    @per_page,
      total:       total,
      total_pages: (total.to_f / @per_page).ceil,
      radius_m:    @geo_enabled ? @radius_m : nil,
      engine:      engine
    }
  end

  def validate_inputs!
    if @geo_enabled
      if @latitude.nil? || @longitude.nil?
        raise ValidationError.new("latitude and longitude are required",
                                  errors: ["latitude is required", "longitude is required"])
      end
      raise ValidationError.new("Invalid latitude",  errors: ["latitude must be between -90 and 90"])  unless @latitude.between?(-90, 90)
      raise ValidationError.new("Invalid longitude", errors: ["longitude must be between -180 and 180"]) unless @longitude.between?(-180, 180)
    end

    return unless @min_rating && !@min_rating.between?(0, 5)

    raise ValidationError.new("Invalid min_rating", errors: ["min_rating must be between 0 and 5"])
  end

  def cache_key
    if @geo_enabled
      [
        "nearby_vendors",
        ("user/#{@cache_scope}" if @cache_scope),
        format("%.3f", @latitude.round(3)),   # ~111m bucket
        format("%.3f", @longitude.round(3)),
        @radius_m.to_i,
        @category || "-",
        @min_rating || "-",
        @open.nil? ? "-" : @open,
        @page, @per_page
      ].compact.join("/")
    else
      [
        "nearby_vendors/global",
        ("user/#{@cache_scope}" if @cache_scope),
        @category || "-",
        @min_rating || "-",
        @open.nil? ? "-" : @open,
        @page, @per_page
      ].compact.join("/")
    end
  end

  def coerce_float(v)
    return nil if v.nil? || v.to_s.strip.empty?

    Float(v)
  rescue ArgumentError, TypeError
    nil
  end

  def coerce_bool(v)
    return nil if v.nil? || v.to_s.strip.empty?

    ActiveModel::Type::Boolean.new.cast(v)
  end
end
