# Lightweight per-request feature flag lookup.
#
# Resolution order (first match wins):
#   1. Rails.cache value under "feature_flag/<key>" — allows runtime toggling
#      without a restart (set via FeatureFlag.set(:key, true/false)).
#   2. ENV "FEATURE_FLAG_<KEY_UPCASE>" — supports per-environment defaults.
#   3. Provided default.
class FeatureFlag
  CACHE_NAMESPACE = "feature_flag"

  class << self
    def enabled?(key, default: false)
      cached = Rails.cache.read(cache_key(key))
      return cast_bool(cached) unless cached.nil?

      env_val = ENV[env_key(key)]
      return cast_bool(env_val) unless env_val.nil?

      default
    end

    def set(key, value)
      Rails.cache.write(cache_key(key), cast_bool(value))
    end

    def clear(key)
      Rails.cache.delete(cache_key(key))
    end

    private

    def cache_key(key)
      "#{CACHE_NAMESPACE}/#{key}"
    end

    def env_key(key)
      "FEATURE_FLAG_#{key.to_s.upcase}"
    end

    def cast_bool(value)
      ActiveModel::Type::Boolean.new.cast(value)
    end
  end
end
