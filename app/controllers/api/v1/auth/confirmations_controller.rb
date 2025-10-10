# frozen_string_literal: true

class Api::V1::Auth::ConfirmationsController < Devise::ConfirmationsController
  include ResponseHandler
  include ExceptionHandler
  # GET /resource/confirmation/new
  # def new
  #   super
  # end

  # POST /resource/confirm_email
  def confirm_email
    user = User.find_by(email: confirmation_params[:email])
    raise ActiveRecord::RecordNotFound, "User not found" if user.nil?
    raise ConfirmedUserError if user.confirmed?
    if confirmation_params[:confirmation_token] != user.confirmation_token
      raise WrongConfirmationTokenError
    end
    user.update!(
      confirmed_at: Time.current,
      confirmation_token: nil
    )
    render_response(message: "Email confirmed successfully", status: 200)
  end

  def resend_confirmation_instructions
    raise ValidationError, "Email is required" if params[:email].nil?
    user = User.find_by(email: params[:email])
    raise ValidationError, "User not found" if user.nil?
    raise ConfirmedUserError if user.confirmed?
    raw_token, enc_token = Devise.token_generator.generate(User, :confirmation_token)
    user.confirmation_token = raw_token
    user.confirmation_sent_at = Time.current
    user.save(validate: false)
    user.send_confirmation_instructions
    render_response(message: "Sent confirmation instructions", status: 200)
  end

  # POST

  # GET /resource/confirmation?confirmation_token=abcdef
  # def show
  #   super
  # end

  # protected

  # The path used after resending confirmation instructions.
  # def after_resending_confirmation_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  # The path used after confirmation.
  # def after_confirmation_path_for(resource_name, resource)
  #   super(resource_name, resource)
  # end

  private

  def confirmation_params
    params.require(:user).permit(:email, :confirmation_token)
  end
end
