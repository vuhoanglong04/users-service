class AddAppointmentSnapshotToAppointment < ActiveRecord::Migration[8.0]
  def change
    add_column :appointments, :appointment_snapshot, :text
  end
end
