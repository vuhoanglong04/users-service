class Api::V1::Admin::DoctorsController < Api::V1::Admin::BaseAdminController
  def index
    page = params[:page].to_i >= 1 ? params[:page].to_i : 1
    per_page = 5
    query = params[:query].to_s.strip

    cache_key = [
      "doctor_profiles_page=#{page}",
      "per_page=#{per_page}",
      "query=#{query}",
    ].compact.join("&")

    Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      results = DoctorProfile.search(
        {
          from: (page - 1) * per_page,
          size: per_page,
          query: query.present? ?
                   {
                     bool: {
                       should: [
                         { term: { "license_number.keyword": query.downcase } },
                         { match: { license_number: query } },
                         { term: { "specialization.keyword": query.downcase } },
                         { match: { specialization: query } },
                         { match: { bio: query } },
                         { match: { gender: query } }
                       ]
                     }
                   } :
                   { match_all: {} }
        }
      )

      meta = es_pagination_meta(results.response, page, per_page)

      serialized_doctors = ActiveModelSerializers::SerializableResource.new(
        results.records,
        each_serializer: Admin::DoctorSerializer
      ).as_json

      {
        data: { doctors: serialized_doctors },
        meta: meta
      }
    end.then do |cached_response|
      render_response(
        data: cached_response[:data],
        message: "Get all doctors successfully",
        status: 200,
        meta: cached_response[:meta]
      )
    end
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
