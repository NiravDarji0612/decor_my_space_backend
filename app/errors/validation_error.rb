class ValidationError < StandardError
  attr_reader :errors

  def initialize(message = "Validation failed", errors: [])
    super(message)
    @errors = Array(errors)
  end
end
