# frozen_string_literal: true

class CheckResetPasswordTokenForm
  include ActiveModel::Model
  include CustomValidateForm

  attr_accessor :email, :reset_password_token
  validates :email,
            presence: { message: "Email is required" },
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "Invalid email format" }
  validates :reset_password_token,
            presence: { message: "Reset password token is required" }

  def initialize(email, reset_password_token)
    super(email: email, reset_password_token: reset_password_token)
    validate!
  end
end
