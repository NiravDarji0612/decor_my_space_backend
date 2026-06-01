# Encapsulates the business rules around persisting a user's current location:
#   - validates the coordinate envelope
#   - updates User#latitude / #longitude / #location_updated_at (triggers PostGIS
#     geom sync via the Geocodable concern)
#   - appends an immutable row to user_location_histories
#   - invalidates any per-user "nearby" caches
#
# Usage:
#   UserLocationService.call(user: current_user, latitude: 23.02, longitude: 72.57)
class UserLocationService
  Result = Struct.new(:user, :history, keyword_init: true)

  def self.call(user:, latitude:, longitude:, accuracy_m: nil, source: "client")
    new(user, latitude, longitude, accuracy_m, source).call
  end

  def initialize(user, latitude, longitude, accuracy_m, source)
    @user       = user
    @latitude   = coerce(latitude)
    @longitude  = coerce(longitude)
    @accuracy_m = accuracy_m && coerce(accuracy_m)
    @source     = source.presence || "client"
  end

  def call
    raise ValidationError.new("Latitude and longitude are required",
                              errors: ["latitude is required", "longitude is required"]) if @latitude.nil? || @longitude.nil?
    raise ValidationError.new("Invalid latitude",  errors: ["latitude must be between -90 and 90"])  unless @latitude.between?(-90, 90)
    raise ValidationError.new("Invalid longitude", errors: ["longitude must be between -180 and 180"]) unless @longitude.between?(-180, 180)

    history = nil
    ActiveRecord::Base.transaction do
      @user.update!(
        latitude:            @latitude,
        longitude:           @longitude,
        location_updated_at: Time.current
      )

      history = @user.location_histories.create!(
        latitude:    @latitude,
        longitude:   @longitude,
        accuracy_m:  @accuracy_m,
        source:      @source,
        recorded_at: Time.current
      )
    end

    invalidate_caches
    Result.new(user: @user, history: history)
  end

  private

  def coerce(val)
    return nil if val.nil? || val.to_s.strip.empty?

    Float(val)
  rescue ArgumentError, TypeError
    nil
  end

  def invalidate_caches
    Rails.cache.delete_matched("nearby_vendors/user/#{@user.id}/*")
  rescue NotImplementedError
    # MemoryStore in test/dev doesn't support delete_matched — safe to ignore.
  end
end
