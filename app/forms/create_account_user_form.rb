# frozen_string_literal: true

class CreateAccountUserForm
  include ActiveModel::Model
  include CustomValidateForm
  attr_accessor :main_role, :email, :status, :password, :password_confirmation, :user_profile_attributes
  validates :email,
            presence: { message: "Email is required" },
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "Invalid email format" }

  validates :full_name,
            presence: true

  validates :phone,
            presence: true

  validates :avatar_url,
            presence: true,
            file_size: { less_than_or_equal_to: 5.megabytes, message: "Avatar must be less than or equal to 5MB" },
            file_content_type: { allow: %w[image/jpeg image/png], message: "Avatar must be image" }

  validates :locale,
            presence: true,
            inclusion: { in: %w[en vi fr de jp],
                         message: "%{value} is not supported" }

  validates :time_zone,
            presence: true

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

  def full_name
    user_profile_attributes[:full_name]
  end

  def phone
    user_profile_attributes[:phone]
  end

  def avatar_url
    user_profile_attributes[:avatar_url]
  end

  def locale
    user_profile_attributes[:locale]
  end

  def time_zone
    user_profile_attributes[:time_zone]
  end
end
