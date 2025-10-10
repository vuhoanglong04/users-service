class SendResetPasswordEmailJob < ApplicationJob
  queue_as :default

  def perform(*args)
    user, token = args
    Rails.logger.info("[SendResetPasswordEmailJob] Start for #{user&.email || 'nil'}")

    return Rails.logger.warn("[SendResetPasswordEmailJob] User is nil — skip.") if user.nil?

    Devise::Mailer.reset_password_instructions(user, token).deliver_now
    Rails.logger.info("[SendResetPasswordEmailJob] Sent reset password email to #{user.email}")
  rescue => e
    Rails.logger.error("[SendResetPasswordEmailJob] Error: #{e.message}")
  end
end
