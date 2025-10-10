class Admin::AppointmentsSerializer < ActiveModel::Serializer
  include SerializerConcern
  attributes :id,
             :doctor,
             :patient,
             :appointment_date,
             :status,
             :notes,
             :appointment_snapshot,
             :updated_at,
             :created_at

  def appointment_date
    object&.appointment_date&.in_time_zone&.strftime("%Y-%m-%d %H:%M:%S")
  end

  def doctor
    Admin::DoctorSerializer.new(object.doctor_profile) if object.doctor_profile.present?
  end

  def patient
    Admin::PatientSerializer.new(object.patient_profile) if object.patient_profile.present?
  end
end
