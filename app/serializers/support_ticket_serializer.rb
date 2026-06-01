class SupportTicketSerializer < ActiveModel::Serializer
  attributes :id, :category, :subject, :message, :status, :created_at

  def created_at
    object.created_at.iso8601
  end
end
