class CreatePatientForm
  include ActiveModel::Model
  include CustomValidateForm

  attr_accessor :user_id,
                :date_of_birth,
                :gender,
                :address,
                :emergency_contact,
                :medical_history,
                :avatar

  validates :user_id,
            presence: { message: "User not valid" }

  validates :avatar,
            presence: { message: "Avatar can't be blank" }

  validates :date_of_birth,
            presence: { message: "Date of birth is required" }

  validates :gender,
            inclusion: { in: %w[male female], message: "Gender must be male or female. We don't welcome gender 'other'" },
            allow_nil: true

  validates :address,
            length: { maximum: 255, message: "Address is too long (maximum is 255 characters)" },
            allow_blank: true

  validates :emergency_contact,
            length: { maximum: 100, message: "Emergency contact is too long (maximum is 100 characters)" },
            allow_blank: true

  def initialize(attributes = {})
    super(attributes)
    validate!
  end
end
