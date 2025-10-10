class SendUnlockEmailJob < ApplicationJob
  queue_as :default

  def perform(user, token)
    if user.nil?
      Rails.logger.warn("[SendUnlockEmailJob] User not found!")
      return
    end

    if user.locked_at.nil?
      Rails.logger.info("[SendUnlockEmailJob] User #{user.email} is not locked. Skipping unlock email.")
      return
    end

    Devise::Mailer.unlock_instructions(user, token).deliver_now
    Rails.logger.info("[SendUnlockEmailJob] Unlock instructions sent to #{user.email}")
  rescue => e
    Rails.logger.error("[SendUnlockEmailJob] Error sending unlock email to #{user&.email}: #{e.message}")
  end
end
