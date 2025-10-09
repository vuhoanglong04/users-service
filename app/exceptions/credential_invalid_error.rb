# frozen_string_literal: true

class CredentialInvalidError < StandardError
  attr_reader :errors

  def initialize(message = "Invalid credentials", errors = {})
    super(message)
    @errors = errors
  end
end
