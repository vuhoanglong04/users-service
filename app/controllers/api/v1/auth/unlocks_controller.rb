# frozen_string_literal: true

class Api::V1::Auth::UnlocksController < Devise::UnlocksController
  include ExceptionHandler
  include ResponseHandler
  # GET /resource/unlock/new
  # def new
  #   super
  # end

  # POST /resource/send_unlock
  def send_unlock
    handle_send_unlock_instructions
  end

  #POST /resource/resend_unlock
  def resend_unlock
    handle_send_unlock_instructions
  end

  # POST /resource/unlock
  def unlock
    raw = unlock_params[:unlock_token]
    digest = Devise.token_generator.digest(User, :unlock_token, raw)

    user = User.find_by(email: unlock_params[:email], unlock_token: digest)

    if user.present?
      user.update!(locked_at: nil, unlock_token: nil, failed_attempts: 0)
      render_response(message: "Account unlocked successfully", status: :ok)
    else
      render_response(message: "Invalid token or email", status: :unprocessable_entity)
    end
  end


  def handle_send_unlock_instructions
    user = User.find_by!(email: unlock_params[:email])

    if !user.locked_at?
      render_response(message: "User account is not locked", status: 400)
    else
      user.send_unlock_instructions
      render_response(message: "Unlock instructions sent successfully", status: 200)
    end
  end

  # protected

  # The path used after sending unlock password instructions
  # def after_sending_unlock_instructions_path_for(resource)
  #   super(resource)
  # end

  # The path used after unlocking the resource
  # def after_unlock_path_for(resource)
  #   super(resource)
  # end

  private

  def unlock_params
    params.permit(:email, :unlock_token)
  end
end
