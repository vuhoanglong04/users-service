class User < ApplicationRecord
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

  # Elasticsearch
end
