class UpdateAppointmentForm
  include ActiveModel::Model
  include CustomValidateForm

  attr_accessor :doctor_id,
                :patient_id,
                :appointment_date,
                :status,
                :notes,
                :appointment_snapshot

  validates :doctor_id,
            presence: { message: "Doctor must be selected" },
            allow_blank: true

  validates :patient_id,
            presence: { message: "Patient must be selected" },
            allow_blank: true

  validates :appointment_date,
            presence: { message: "Appointment date can't be blank" },
            allow_blank: true

  validates :status,
            inclusion: {
              in: %w[pending confirmed cancelled completed],
              message: "Status must be one of: pending, confirmed, cancelled, completed"
            },
            allow_blank: true

  validates :notes,
            length: { maximum: 500, message: "Notes can't exceed 500 characters" },
            allow_blank: true

  def initialize(attributes = {})
    super(attributes)
    validate!
  end
end
