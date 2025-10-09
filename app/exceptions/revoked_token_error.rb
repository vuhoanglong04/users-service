class RevokedTokenError < StandardError
  attr_accessor :errors

  def initialize(message = "Already logged out", errors = {})
    super(message)
    @errors = errors
  end
end
