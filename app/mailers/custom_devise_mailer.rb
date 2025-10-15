class CustomDeviseMailer < ApplicationMailer
  default from: "longprovip2508@gmail.com"
  layout "mailer"

  # Confirmation email
  def confirmation_instructions(record, token, opts = {})
    payload = {
      type: "confirmation_instructions",
      email: record.email,
      token: token
    }
    $kafka.deliver_message(payload.to_json, topic: "email")
  end

  # Reset password email
  def reset_password_instructions(record, token, opts = {})
    payload = {
      type: "reset_password_instructions",
      email: record.email,
      token: token
    }
    $kafka.deliver_message(payload.to_json, topic: "email")
  end

  def unlock_instructions(record, token, opts = {})
    payload = {
      type: "unlock_instructions",
      email: record.email,
      token: token
    }
    $kafka.deliver_message(payload.to_json, topic: "email")
  end
end
