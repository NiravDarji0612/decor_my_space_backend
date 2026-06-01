module Api
  module V1
    class NotificationsController < BaseController
      include Authenticatable

      def index
        scope = policy_scope(Notification).recent
        scope = scope.unread if ActiveModel::Type::Boolean.new.cast(params[:unread])
        records, meta = paginate(scope)
        render_success(
          data: {
            notifications: serialize_collection(records, serializer: NotificationSerializer),
            unread_count:  policy_scope(Notification).unread.count
          },
          meta: meta
        )
      end

      def read_all
        policy_scope(Notification).unread.update_all(read_at: Time.current)
        render_success(message: "All notifications marked as read")
      end

      def destroy
        notification = current_user.notifications.find(params[:id])
        authorize notification
        notification.destroy!
        render_success(message: "Notification dismissed")
      end
    end
  end
end
