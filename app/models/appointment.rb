# frozen_string_literal: true

class Appointment < ApplicationRecord
  enum :status, {
    pending: 'pending',
    confirmed: 'confirmed',
    cancelled: 'cancelled',
    completed: 'completed'
  }
  belongs_to :doctor_profile, class_name: 'DoctorProfile', foreign_key: 'doctor_id'
  belongs_to :patient_profile, class_name: 'PatientProfile', foreign_key: 'patient_id'

  validate :doctor_or_patient_has_conflict

  private

  def doctor_or_patient_has_conflict
    conflict = Appointment.where(appointment_date: appointment_date)
                          .where.not(id: id)
                          .where("doctor_id = ? OR patient_id = ?", doctor_id, patient_id)
                          .exists?

    raise ValidationError.new("There is an appointment in your schedule or doctor's schedule at the selected date/time") if conflict
  end
end
