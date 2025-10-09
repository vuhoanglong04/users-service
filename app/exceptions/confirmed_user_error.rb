# frozen_string_literal: true

class ConfirmedUserError < StandardError
  attr_reader :errors

  def initialize(message = "Email is confirmed", errors = {})
    super(message)
    @errors = errors
  end
end
