class RemoveDoctorIdFromBillings < ActiveRecord::Migration[8.0]
  def change
    remove_column :billings, :doctor_id
  end
end
