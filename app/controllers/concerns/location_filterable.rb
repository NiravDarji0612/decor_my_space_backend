module LocationFilterable
  extend ActiveSupport::Concern

  LOCATION_FLAG = :show_records_based_on_location

  private

  def location_filtering_enabled?
    return @location_filtering_enabled unless @location_filtering_enabled.nil?

    @location_filtering_enabled = FeatureFlag.enabled?(LOCATION_FLAG, default: true)
    Rails.logger.info(
      "location_filter=#{@location_filtering_enabled ? 'on' : 'off'} " \
      "controller=#{controller_path} action=#{action_name}"
    )
    @location_filtering_enabled
  end
end
