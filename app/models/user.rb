class User < ApplicationRecord
  include RemoveCacheAfterCommitting
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :confirmable,
         :lockable,
         :jwt_authenticatable,
         :omniauthable,
         omniauth_providers: [:google_oauth2],
         lock_strategy: :failed_attempts, unlock_strategy: :both,
         jwt_revocation_strategy: JwtRedisDenyList
  # Enum
  enum :role, { admin: 0, user: 1 }
  # Relationships
  has_one :patient_profile, dependent: :destroy
  has_one :doctor_profile, dependent: :destroy
  has_many :appointments
  has_many :posts
  has_many :comments, dependent: :destroy

  # Validation
  validates :email,
            presence: true,
            uniqueness: { case_sensitive: true }
  # Soft Delete
  acts_as_paranoid

  # Elasticsearch
  settings index: {
    number_of_shards: 2,
    analysis: {
      my_vietnamese_analyzer: {
        tokenizer: "standard",
        filter: %w[lowercase asciifolding]
      }
    }
  } do
    mapping dynamic: false do
      indexes :email, type: :text, analyzer: :standard do
        indexes :keyword, type: :keyword
      end
      indexes :first_name, type: :text, analyzer: :standard
      indexes :last_name, type: :text, analyzer: :standard
      indexes :phone_number, type: :text, analyzer: :standard
      indexes :updated_at, type: :date
      indexes :created_at, type: :date
    end
  end

  private

  def as_indexed_json(options = {})
    {
      id: id,
      email: email,
      first_name: first_name,
      last_name: last_name,
      phone_number: phone_number,
      avatar: avatar,
      provider: provider,
      role: role,
      deleted_at: deleted_at,
      updated_at: updated_at,
      created_at: created_at
    }
  end
end
