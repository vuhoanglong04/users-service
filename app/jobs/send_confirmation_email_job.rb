class SendConfirmationEmailJob < ApplicationJob
  queue_as :default

  def perform(*args)
    user, token = args
    Rails.logger.info("[SendConfirmationEmailJob] Start for #{user&.email || 'nil'}")

    return Rails.logger.warn("[SendConfirmationEmailJob] User is nil — skip.") if user.nil?

    Devise::Mailer.confirmation_instructions(user, token).deliver_now
    Rails.logger.info("[SendConfirmationEmailJob] Sent confirmation email to #{user.email}")
  rescue => e
    Rails.logger.error("[SendConfirmationEmailJob] Error: #{e.message}")
  end
end
