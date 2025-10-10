class Admin::DoctorSerializer < ActiveModel::Serializer
  attributes :id,
             :user_id,
             :specialization,
             :license_number,
             :experience_years,
             :bio,
             :avatar,
             :gender
end
