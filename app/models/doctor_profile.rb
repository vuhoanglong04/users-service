# frozen_string_literal: true

class DoctorProfile < ApplicationRecord
  belongs_to :user
  has_many :appointments
  enum :gender, { male: 'male', female: 'female' }
end
