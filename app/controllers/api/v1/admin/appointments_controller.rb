class Api::V1::Admin::AppointmentsController < Api::V1::Admin::BaseAdminController
  def index
    page = params[:page] ||= 1
    appointments = Appointment.page(page).per(5)
    render_response(
      data: {
        appointments: ActiveModelSerializers::SerializableResource.new(appointments, each_serializer: Admin::AppointmentsSerializer)
      },
      message: "Get all appointments successfully.",
      status: 200
    )
  end

  def create
    CreateAppointmentForm.new(appointment_params)
    appointment = Appointment.new(appointment_params)
    if appointment.save
      render_response(
        data: {
          appointment: ActiveModelSerializers::SerializableResource.new(appointment, serializer: Admin::AppointmentsSerializer)
        },
        message: "Create appointment successfully",
        status: 201
      )
    else
      raise ValidationError.new("Validation failed", appointment.errors)
    end
  end

  def update
    UpdateAppointmentForm.new(appointment_params)
    appointment = Appointment.find_by(id: params[:id])
    raise ActiveRecord::RecordNotFound, "Appointment not found" if appointment.nil?
    if appointment.update(appointment_params)
      render_response(
        data: {
          appointment: ActiveModelSerializers::SerializableResource.new(appointment, serializer: Admin::AppointmentsSerializer)
        },
        message: "Update appointment successfully",
        status: 200
      )
    else
      raise ValidationError.new("Validation failed", appointment.errors)
    end
  end

  private

  def appointment_params
    params.permit(:doctor_id, :patient_id, :appointment_date, :status, :notes, :appointment_snapshot)
  end
end
