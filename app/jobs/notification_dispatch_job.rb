class NotificationDispatchJob < ApplicationJob
  queue_as :default

  def perform(user_id:, title:, body:, kind: "system", payload: {})
    user = User.active.find_by(id: user_id)
    return unless user

    prefs = user.preferences
    return unless allowed_by_preferences?(prefs, kind)

    Notification.create!(
      user:    user,
      title:   title,
      body:    body,
      kind:    kind,
      payload: payload,
      delivered_at: Time.current
    )
    # TODO: push notification provider (FCM/APNs) integration
  end

  private

  def allowed_by_preferences?(prefs, kind)
    case kind.to_s
    when "booking"   then prefs.notify_bookings
    when "promotion" then prefs.notify_promotions
    else                  prefs.notify_system
    end
  end
end
