class Api::V1::Admin::PatientsController < Api::V1::Admin::BaseAdminController
  def index
    page = params[:page].to_i >= 1 ? params[:page].to_i : 1
    per_page = 5
    query = params[:query].to_s.strip

    cache_key = [
      "patient_profiles_page=#{page}",
      "per_page=#{per_page}",
      "query=#{query}",
    ].compact.join("&")

    Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      results = PatientProfile.search(
        {
          from: (page - 1) * per_page,
          size: per_page,
          query: query.present? ?
                   {
                     bool: {
                       should: [
                         { multi_match: { query: query, fields: %w[gender address emergency_contact medical_history] } }
                       ]
                     }
                   } :
                   { match_all: {} }
        }
      )

      meta = es_pagination_meta(results.response, page, per_page)

      serialized_patients = ActiveModelSerializers::SerializableResource.new(
        results.records,
        each_serializer: Admin::PatientSerializer
      ).as_json

      {
        data: { patients: serialized_patients },
        meta: meta
      }
    end.then do |cached_response|
      render_response(
        data: cached_response[:data],
        message: "Get all patients successfully",
        status: 200,
        meta: cached_response[:meta]
      )
    end
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
