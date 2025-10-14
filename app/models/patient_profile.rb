# frozen_string_literal: true

class PatientProfile < ApplicationRecord
  include RemoveCacheAfterCommitting
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  enum :gender, { male: 'male', female: 'female' }
  belongs_to :user
  has_many :appointments
  has_many :billings

  settings index: {
    number_of_shards: 2
  } do
    mapping dynamic: false do
      indexes :gender, type: :text, analyzer: :standard
      indexes :address, type: :text, analyzer: :standard
      indexes :emergency_contact, type: :text, analyzer: :standard
      indexes :medical_history, type: :text, analyzer: :standard
    end
  end

  def as_indexed_json(_options = {})
    {
      id: id,
      user_id: user_id,
      date_of_birth: date_of_birth,
      gender: gender,
      address: address,
      emergency_contact: emergency_contact,
      medical_history: medical_history,
      avatar: avatar
    }
  end

end
