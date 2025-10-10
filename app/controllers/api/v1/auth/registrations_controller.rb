# frozen_string_literal: true

class Api::V1::Auth::RegistrationsController < Devise::RegistrationsController
  include ResponseHandler
  include ExceptionHandler
  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
    SignupForm.new(sign_up_params)
    build_resource(sign_up_params)
    if resource.save
      render_response(
        data: {
          user: ActiveModelSerializers::SerializableResource.new(resource, serializer: LoginSerializer)
        },
        status: 201,
        message: "Signup successfully. Please confirm your email address before continuing."
      )
    else
      raise ActiveRecord::RecordInvalid.new(resource)
    end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end

  private

  def sign_up_params
    params.require(:user).permit(:email, :first_name, :last_name, :phone_number, :password, :password_confirmation)
  end
end
