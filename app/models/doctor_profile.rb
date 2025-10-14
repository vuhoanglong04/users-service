# frozen_string_literal: true

class DoctorProfile < ApplicationRecord
  include RemoveCacheAfterCommitting
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  belongs_to :user
  has_many :appointments
  enum :gender, { male: "male", female: "female" }

  settings index: {
    number_of_shards: 2
  } do
    mapping dynamic: false do
      indexes :license_number, type: :text, analyzer: :standard do
        indexes :keyword, type: :keyword
      end
      indexes :specialization, type: :text, analyzer: :standard do
        indexes :keyword, type: :keyword
      end
      indexes :bio, type: :text, analyzer: :standard
      indexes :gender, type: :text, analyzer: :standard
    end
  end

  def as_indexed_json(_options = {})
    {
      id: id,
      user_id: user_id,
      specialization: specialization,
      license_number: license_number,
      experience_years: experience_years,
      bio: bio,
      avatar: avatar,
      gender: gender,
      updated_at: updated_at,
      created_at: created_at
    }
  end
end
