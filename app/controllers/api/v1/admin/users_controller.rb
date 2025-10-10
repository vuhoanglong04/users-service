class Api::V1::Admin::UsersController < Api::V1::Admin::BaseAdminController
  def index
    page = params[:page] ||= 1
    users = User.with_deleted.all.page(page).per(5)
    render_response(
      data: {
        users: ActiveModelSerializers::SerializableResource.new(users, each_serializer: Admin::UserSerializer)
      },
      message: "Get all user successfully",
      status: 200,
      meta: pagination_meta(users)
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
