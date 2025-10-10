class Api::V1::Admin::PatientsController < Api::V1::Admin::BaseAdminController
  def index
    page = params[:page] ||= 1
    patients = PatientProfile.page(page).per(5)
    render_response(
      data: {
        patients: ActiveModelSerializers::SerializableResource.new(patients, each_serializer: Admin::PatientSerializer)
      },
      message: "Get all patients successfully",
      status: 200,
      meta: pagination_meta(patients)
    )
  end

  def create
    CreatePatientForm.new(patients_params)
    avatar = S3UploadService.upload(patients_params[:avatar], "patients")
    patient = PatientProfile.new(patients_params.except(:avatar).merge(avatar: avatar))
    if patient.save
      render_response(
        data: {
          patient: ActiveModelSerializers::SerializableResource.new(patient, serializer: Admin::PatientSerializer)
        },
        message: "Create patient successfully",
        status: 201
      )
    else
      raise ValidationError.new("Validation failed", patient.errors)
    end
  end

  def update
    UpdatePatientForm.new(patients_params)
    patient = PatientProfile.find_by(id: params[:id])
    raise ActiveRecord::RecordNotFound, "Patient not found" if patient.nil?
    if patients_params[:avatar]
      S3UploadService.delete_by_url(patient.avatar) if patient.avatar
      avatar = S3UploadService.upload(patients_params[:avatar], "patients")
    end

    if patient.update(avatar ? patients_params.except(:avatar).merge(avatar: avatar) : patients_params)
      render_response(
        data: {
          patient: ActiveModelSerializers::SerializableResource.new(patient, serializer: Admin::PatientSerializer)
        },
        message: "Update patient successfully",
        status: 201
      )
    else
      raise ValidationError.new("Validation failed", patient.errors)
    end
  end

  def destroy
    patient = PatientProfile.find_by(id: params[:id])
    raise ActiveRecord::RecordNotFound, "Patient not found" if patient.nil?
    patient.destroy
    render_response(message: "Deleted patient", status: 200)
  end

  def restore
    patient = PatientProfile.find_by(id: params[:id])
    raise ActiveRecord::RecordNotFound, "Patient not found" if patient.nil?
    PatientProfile.restore(params[:id])
    render_response(message: "Restored patient", status: 200)
  end

  private

  def patients_params
    params.permit(:user_id, :date_of_birth, :gender, :address, :emergency_contact, :medical_history, :avatar)
  end
end
