class Admin::BillingSerializer < ActiveModel::Serializer
  attributes :id,
             :appointment_id,
             :doctor_id,
             :patient_id,
             :amount,
             :status,
             :payment_method
end
