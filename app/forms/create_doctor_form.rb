class CreateDoctorForm
  include ActiveModel::Model
  include CustomValidateForm

  attr_accessor :user_id,
                :specialization,
                :license_number,
                :experience_years,
                :bio,
                :avatar,
                :gender

  validates :user_id,
            presence: { message: "User not valid" }

  validates :avatar,
            presence: { message: "Avatar can't be blank" }

  validates :specialization,
            presence: { message: "Specialization is required" },
            length: { maximum: 100, message: "Specialization is too long (maximum is 100 characters)" }

  validates :license_number,
            presence: { message: "License number is required" },
            length: { maximum: 50, message: "License number is too long (maximum is 50 characters)" }

  validates :experience_years,
            presence: { message: "Experience years is required" },
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0,
              less_than_or_equal_to: 100,
              message: "Experience years must be a number between 0 and 100"
            }

  validates :bio,
            length: { maximum: 1000, message: "Bio is too long (maximum is 1000 characters)" },
            allow_blank: true

  def initialize(attributes = {})
    super(attributes)
    validate!
  end
end
