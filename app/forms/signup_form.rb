# frozen_string_literal: true

class SignupForm
  include ActiveModel::Model
  include CustomValidateForm

  attr_accessor :email,
                :first_name,
                :last_name,
                :phone_number,
                :password,
                :password_confirmation

  validates :email,
            presence: { message: "Email is required" },
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "Invalid email format" }

  validates :first_name,
            presence: { message: "First name is required" }

  validates :last_name,
            presence: { message: "Last name is required" }

  validates :phone_number,
            presence: { message: "Phone number is required" }

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

  private

  def passwords_match
    return if password == password_confirmation
    errors.add(:password_confirmation, "Password doesn't match")
  end
end
