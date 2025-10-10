class Api::V1::Admin::DoctorsController < Api::V1::Admin::BaseAdminController
  def index
    page = params[:page] ||= 1
    doctors = DoctorProfile.page(page).per(5)
    render_response(
      data: {
        doctors: ActiveModelSerializers::SerializableResource.new(doctors, each_serializer: Admin::DoctorSerializer)
      },
      message: "Get all doctors successfully",
      status: 200,
      meta: pagination_meta(doctors)
    )
  end

  def create
    CreateDoctorForm.new(doctor_params)
    avatar = S3UploadService.upload(doctor_params[:avatar], "doctors")
    doctor = DoctorProfile.new(doctor_params.except(:avatar).merge(avatar: avatar))
    if doctor.save
      render_response(
        data: {
          doctor: ActiveModelSerializers::SerializableResource.new(doctor, serializer: Admin::DoctorSerializer)
        },
        message: "Create doctor successfully",
        status: 201
      )
    else
      raise ValidationError.new("Validation failed", doctor.errors)
    end
  end

  def update
    UpdateDoctorForm.new(doctor_params)
    doctor = DoctorProfile.find_by(id: params[:id])
    raise ActiveRecord::RecordNotFound, "Doctor not found" if doctor.nil?
    if doctor_params[:avatar]
      S3UploadService.delete_by_url(doctor.avatar) if doctor.avatar
      avatar = S3UploadService.upload(doctor_params[:avatar], "doctors")
    end

    if doctor.update(avatar ? doctor_params.except(:avatar).merge(avatar: avatar) : doctor_params)
      render_response(
        data: {
          doctor: ActiveModelSerializers::SerializableResource.new(doctor, serializer: Admin::DoctorSerializer)
        },
        message: "Update doctor successfully",
        status: 201
      )
    else
      raise ValidationError.new("Validation failed", doctor.errors)
    end
  end

  def destroy
    doctor = DoctorProfile.find_by(id: params[:id])
    raise ActiveRecord::RecordNotFound, "Doctor not found" if doctor.nil?
    doctor.destroy
    render_response(message: "Deleted doctor", status: 200)
  end

  private

  def doctor_params
    params.permit(
      :user_id,
      :specialization,
      :license_number,
      :experience_years,
      :bio,
      :avatar,
      :gender
    )
  end
end
