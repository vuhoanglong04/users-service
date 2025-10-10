# app/controllers/concerns/exception_handler.rb
module ExceptionHandler
  extend ActiveSupport::Concern
  included do
    rescue_from(ActionController::ParameterMissing) do |_e|
      render json: {
        status: 400,
        message: "Missing or invalid parameters"
      }
    end

    rescue_from AuthenticationError, ValidationError do |e|
      render_response(message: e.message, errors: e.errors, status: 401)
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      render_response(message: "Validation failed", errors: e.record.errors.full_messages, status: 401)
    end

    rescue_from ActiveRecord::RecordNotFound do |e|
      render_response(message: e.message, status: 404)
    end

    rescue_from Pundit::NotAuthorizedError do |e|
      render_response(message: "You are not permitted", status: 401)
    end

    rescue_from ConfirmedUserError do |e|
      render_response(message: e.message, status: 422)
    end

    rescue_from CredentialInvalidError do |e|
      render_response(message: e.message, status: 401)
    end

    rescue_from WrongConfirmationTokenError do |e|
      render_response(message: e.message, status: 422)
    end

    rescue_from JWT::ExpiredSignature do |e|
      render_response(message: "Token is invalid", status: 423)
    end
  end
end
