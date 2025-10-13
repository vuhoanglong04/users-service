class Admin::PostSerializer < ActiveModel::Serializer
  include SerializerConcern
  attributes :id,
             :user_id,
             :title,
             :content,
             :image_url,
             :deleted_at,
             :updated_at,
             :created_at
end

