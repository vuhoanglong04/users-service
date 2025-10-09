# frozen_string_literal: true

class WrongConfirmationTokenError < StandardError
  attr_reader :errors

  def initialize(message = "Confirmation token is invalid", errors = {})
    super(message)
    @errors = errors
  end
end
