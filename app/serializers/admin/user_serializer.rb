class Admin::UserSerializer < ActiveModel::Serializer
  include SerializerConcern
  attributes :id,
             :email,
             :first_name,
             :last_name,
             :phone_number,
             :avatar,
             :provider,
             :role,
             :updated_at,
             :created_at
end
