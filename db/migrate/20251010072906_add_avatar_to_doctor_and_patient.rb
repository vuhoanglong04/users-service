class AddAvatarToDoctorAndPatient < ActiveRecord::Migration[8.0]
  def change
    add_column :doctor_profiles, :avatar, :text, default: ""
    add_column :patient_profiles, :avatar, :text, default: ""
  end
end
