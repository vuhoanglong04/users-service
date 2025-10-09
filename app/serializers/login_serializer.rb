class LoginSerializer < ActiveModel::Serializer
  attributes :email, :name, :phone_number, :role
end
