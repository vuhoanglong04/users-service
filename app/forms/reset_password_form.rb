# frozen_string_literal: true

class ResetPasswordForm
  include ActiveModel::Model
  include CustomValidateForm

  attr_accessor :password, :password_confirmation, :email


  validates :email,
            presence: { message: "Email is required" },
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "Invalid email format" }

  validates :password,
            presence: { message: "Password is required" },
            length: { minimum: 6, message: "Password is too short (minimum is 6 characters)" }

  validates :password_confirmation,
            presence: { message: "Password confirmation is required" }

  validate :passwords_match

  def initialize(attributes = {})
    super(attributes)
    validate!
  end
  def passwords_match
    return if password == password_confirmation
    errors.add(:password_confirmation, "Password doesn't match")
  end
end
