class DecoratorDetailSerializer < DecoratorSerializer
  attribute :bio
  has_many :designs, serializer: DesignSummarySerializer
end
