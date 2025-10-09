class CreatePatientProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :patient_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date_of_birth
      t.string :gender, limit: 10
      t.string :address
      t.string :emergency_contact
      t.text :medical_history

      t.timestamps
    end
  end
end
