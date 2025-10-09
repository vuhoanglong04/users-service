# frozen_string_literal: true

class Api::V1::Auth::PasswordsController < Devise::PasswordsController
  include ResponseHandler
  include ExceptionHandler
  # GET /resource/password/new
  # def new
  #   super
  # end

  # POST /resource/password
  def create
    raise ValidationError, "Email is required" if password_params[:email].nil?
    self.resource = resource_class.send_reset_password_instructions(email: password_params[:email])
    if resource.errors.empty?
      render_response(message: "Successfully. Please check your email", status: 200)
    else
      render_response(
        message: resource.errors.full_messages.join(""),
        status: 422
      )
    end
  end

  # POST /resource/reset_password
  def update_password
    CheckResetPasswordTokenForm.new(password_params[:email], password_params[:reset_password_token])
    digested = Devise.token_generator.digest(User, :reset_password_token, params[:reset_password_token])
    user = User.find_by(email: password_params[:email], reset_password_token: digested)
    if user&.reset_password_period_valid?
      ResetPasswordForm.new(password_params.except(:reset_password_token))
      user.update!(password: password_params[:password],
                   password_confirmation: password_params[:password_confirmation],
                   reset_password_token: nil,
                   reset_password_sent_at: nil
      )
      render_response(message: "Update password successfully", status: 200)
    else
      raise ValidationError, "Reset password token is invalid or expired"
    end
  end


  # GET /resource/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/password
  # def update
  #   super
  # end

  # protected

  # def after_resetting_password_path_for(resource)
  #   super(resource)
  # end

  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  def password_params
    params.permit(:reset_password_token, :email, :password, :password_confirmation)
  end
end
