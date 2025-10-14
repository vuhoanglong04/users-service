class Admin::BillingSerializer < ActiveModel::Serializer
  include SerializerConcern
  attributes :id,
             :appointment_id,
             :patient_id,
             :amount,
             :status,
             :payment_method,
             :patient,
             :updated_at,
             :created_at

  def patient
    {
      first_name: object&.patient_profile&.user&.first_name,
      last_name: object&.patient_profile&.user&.last_name,
      email: object&.patient_profile&.user&.email,
      emergency_contact: object&.patient_profile&.emergency_contact
    }
  end
end
