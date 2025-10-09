# frozen_string_literal: true

class AccountLockedError < StandardError
  attr_reader :errors

  def initialize(message = "Account is locked", errors = {})
    super(message)
    @errors = errors
  end
end
