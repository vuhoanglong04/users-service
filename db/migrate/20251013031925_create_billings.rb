class CreateBillings < ActiveRecord::Migration[7.1]
  def change
    create_table :billings do |t|
      t.integer :appointment_id, null: false
      t.integer :doctor_id, null: false
      t.integer :patient_id, null: false
      t.decimal :amount, precision: 10, scale: 2, default: 0.0
      t.string :status, default: "unpaid"      # unpaid, paid, refunded
      t.string :payment_method, default: "GMO"
      t.timestamps
    end
    add_foreign_key :billings, :doctor_profiles, column: :doctor_id
    add_foreign_key :billings, :patient_profiles, column: :patient_id
    add_foreign_key :billings, :appointments, column: :appointment_id
  end
end
