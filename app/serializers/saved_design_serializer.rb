class SavedDesignSerializer < ActiveModel::Serializer
  attributes :id, :created_at

  belongs_to :design, serializer: DesignSummarySerializer

  def created_at
    object.created_at.iso8601
  end
end
