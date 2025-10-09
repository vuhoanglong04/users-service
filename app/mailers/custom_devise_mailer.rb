class CustomDeviseMailer < ApplicationMailer
  default from: "longprovip2508@gmail.com"
  layout "mailer"
  # Confirmation email
  def confirmation_instructions(record, token, opts = {})
    SendConfirmationEmailJob.perform_later(record.email, token)
  end

  # Reset password email
  def reset_password_instructions(record, token, opts = {})
    SendResetPasswordEmailJob.perform_later(record.email, token)
  end

  def unlock_instructions(record, token, opts = {})
    SendResetPasswordEmailJob.perform_later(record.email, token)
  end
end
