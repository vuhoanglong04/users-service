class Api::V1::Admin::UsersController < Api::V1::Admin::BaseAdminController
  def index
    page = params[:page].to_i >= 1 ? params[:page].to_i : 1
    per_page = 5
    query = params[:query].to_s.strip

    cache_key = [
      "user_page=#{page}",
      "per_page=#{per_page}",
      "query=#{query}",
    ].compact.join("&")

    Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      results = User.search(
        {
          from: (page - 1) * per_page,
          size: per_page,
          query: query.present? ?
                   {
                     bool: {
                       should: [
                         { term: { "email.keyword": query.downcase } },
                         { match: { email: query } },
                         { match: { first_name: query } },
                         { match: { last_name: query } },
                         { term: { phone_number: query } }
                       ]
                     }
                   } :
                   { match_all: {} }
        }
      )

      meta = es_pagination_meta(results.response, page, per_page)

      serialized_users = ActiveModelSerializers::SerializableResource.new(
        results.records,
        each_serializer: Admin::UserSerializer
      ).as_json

      {
        data: { users: serialized_users },
        meta: meta
      }
    end.then do |cached_response|
      render_response(
        data: cached_response[:data],
        message: "Get all users successfully",
        status: 200,
        meta: cached_response[:meta]
      )
    end
  end

  def show
    user = User.find_by(id: params[:id])
    raise ActiveRecord::RecordNotFound, "User not found" if user.nil?
    client = AppointmentsClient.new
    response = client.get_appointments_by_patient_id(user.patient_profile.id)
    begin
      appointments = response.appointments.map do |appt|
        {
          id: appt.id,
          doctor_id: appt.doctor_id,
          patient_id: appt.patient_id,
          appointment_date: appt.appointment_date,
          status: appt.status,
          appointment_snapshot: appt.appointment_snapshot,
          updated_at: appt.updated_at,
          created_at: appt.created_at
        }
      end
    rescue GRPC::BadStatus => e
      Rails.logger.error("gRPC error: #{e.details}")
      appointments = []
    end
    render_response(
      data: {
        user: ActiveModelSerializers::SerializableResource.new(user, serializer: Admin::UserSerializer),
        appointments: appointments
      },
      message: "Get user successfully",
      status: 200
    )
  end

  def create
    CreateUserForm.new(user_params)
    avatar = S3UploadService.upload(user_params[:avatar], "users")
    user = User.new(user_params.except(:avatar).merge(avatar: avatar))
    user.skip_confirmation!
    if user.save
      render_response(
        data: {
          user: ActiveModelSerializers::SerializableResource.new(user, serializer: Admin::UserSerializer)
        },
        message: "Create user successfully",
        status: 201
      )
    else
      raise ValidationError.new("Validation failed", user.errors)
    end
  end

  def update
    UpdateUserForm.new(user_params)
    user = User.with_deleted.find_by(id: params[:id])
    raise ActiveRecord::RecordNotFound, "User not found" if user.nil?
    if user_params[:avatar]
      S3UploadService.delete_by_url(user.avatar) if user.avatar
      avatar = S3UploadService.upload(user_params[:avatar], "users")
    end
    if user.update(avatar ? user_params.except(:avatar).merge(avatar: avatar) : user_params)
      render_response(
        data: {
          user: ActiveModelSerializers::SerializableResource.new(user, serializer: Admin::UserSerializer)
        },
        message: "Update user successfully",
        status: 200
      )
    else
      raise ValidationError.new("Validation failed", user.errors)
    end
  end

  def destroy
    user = User.without_deleted.find_by(id: params[:id])
    raise ActiveRecord::RecordNotFound, "User not found" if user.nil?
    user.destroy
    render_response(message: "Deleted user", status: 200)
  end

  def restore
    user = User.only_deleted.find_by(id: params[:id])
    raise ActiveRecord::RecordNotFound, "User not found" if user.nil?
    User.restore(params[:id])
    render_response(message: "Restored user", status: 200)
  end

  private

  def user_params
    params.permit(:email, :first_name, :last_name, :password, :avatar, :phone_number)
  end
end
