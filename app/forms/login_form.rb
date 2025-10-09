# frozen_string_literal: true

class LoginForm
  include ActiveModel::Model
  include CustomValidateForm
  attr_accessor :email, :password
  validates :email,
            presence: { message: "Email is required" },
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "Invalid email format" }
  validates :password,
            presence: { message: "Password is required" },
            length: { minimum: 6, message: "Password is too short (minimum is 6 characters)" }

  def initialize(attributes = {})
    super(attributes)
    validate!
  end
end
