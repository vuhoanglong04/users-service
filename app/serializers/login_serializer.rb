class LoginSerializer < ActiveModel::Serializer
  attributes :email, :first_name, :last_name, :avatar, :phone_number, :role
end
