class CreateAppointments < ActiveRecord::Migration[7.1]
  def change
    create_table :appointments do |t|
      t.integer :doctor_id, null: false
      t.integer :patient_id, null: false
      t.datetime :appointment_date, null: false
      t.string :status, null: false, default: 'pending'
      t.text :notes

      t.timestamps
    end

    add_foreign_key :appointments, :doctor_profiles, column: :doctor_id
    add_foreign_key :appointments, :patient_profiles, column: :patient_id
  end
end
