class DesignSerializer < DesignSummarySerializer
  attribute :description

  attribute :gallery do
    object.images.map(&:url)
  end

  attribute :inclusions do
    object.inclusions.map { |i| { label: i.label, icon_key: i.icon_key } }
  end

  belongs_to :decorator, serializer: DecoratorSerializer
  belongs_to :category,  serializer: CategorySerializer
end
