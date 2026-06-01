class ReviewSerializer < ActiveModel::Serializer
  attributes :id, :rating, :comment, :tags, :would_recommend, :created_at

  def created_at
    object.created_at.iso8601
  end
end
