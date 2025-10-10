class Admin::PatientSerializer < ActiveModel::Serializer
  attributes :id,
             :user_id,
             :date_of_birth,
             :gender,
             :address,
             :emergency_contact,
             :medical_history,
             :avatar
end
