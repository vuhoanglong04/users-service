# frozen_string_literal: true

class Api::V1::Auth::UnlocksController < Devise::UnlocksController
  include ExceptionHandler
  include ResponseHandler
  # GET /resource/unlock/new
  # def new
  #   super
  # end

  # POST /resource/unlock
  def create
    User.send_unlock_instructions(email: unlock_params[:email])
    # render_response(message: "Unlock instructions sent successfully", status: 201)
  end

  # GET /resource/unlock?unlock_token=abcdef
  # def show
  #   super
  # end

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
    params.permit(:email)
  end
end
