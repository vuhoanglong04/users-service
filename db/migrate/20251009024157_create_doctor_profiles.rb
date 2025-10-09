class CreateDoctorProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :doctor_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :specialization, null: false
      t.string :license_number, null: false
      t.integer :experience_years, default: 0
      t.text :bio

      t.timestamps
    end
  end
end
