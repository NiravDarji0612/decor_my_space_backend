class NotificationSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :kind, :payload, :unread, :created_at

  def unread
    object.read_at.nil?
  end

  def created_at
    object.created_at.iso8601
  end
end
