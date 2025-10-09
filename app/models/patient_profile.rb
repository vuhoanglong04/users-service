# frozen_string_literal: true

class PatientProfile < ApplicationRecord
  enum :gender, { male: 'male', female: 'female' }
  belongs_to :user
  has_many :appointments
end
