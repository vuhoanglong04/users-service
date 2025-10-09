# frozen_string_literal: true

class ValidationError < StandardError
  attr_accessor :errors

  def initialize(message = "Validation failed", errors = {})
    super(message)
    @errors = errors
  end
end
