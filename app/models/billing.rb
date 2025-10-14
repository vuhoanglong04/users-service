# frozen_string_literal: true

class Billing < ApplicationRecord
  include RemoveCacheAfterCommitting
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  belongs_to :patient_profile, foreign_key: 'patient_id'
  belongs_to :appointment

  settings index: {
    number_of_shards: 2
  } do
    mapping dynamic: false do
      indexes :amount, type: :float
      indexes :status, type: :text, analyzer: :standard do
        indexes :keyword, type: :keyword
      end
      indexes :payment_method, type: :text, analyzer: :standard do
        indexes :keyword, type: :keyword
      end
      indexes :patient, type: :object do
        indexes :first_name, type: :text, analyzer: :standard
        indexes :last_name, type: :text, analyzer: :standard
        indexes :emergency_contact, type: :text, analyzer: :standard
        indexes :email, type: :text, analyzer: :standard do
          indexes :keyword, type: :keyword
        end
      end
    end
  end

  def as_indexed_json(options = {})
    {
      id: id,
      amount: amount,
      status: status,
      payment_method: payment_method,
      patient: {
        first_name: patient_profile&.user&.first_name,
        last_name: patient_profile&.user&.last_name,
        email: patient_profile&.user&.email,
        emergency_contact: patient_profile&.emergency_contact
      },
      updated_at: updated_at,
      created_at: created_at,
    }
  end
end
