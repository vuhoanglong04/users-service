class SendResetPasswordEmailJob < ApplicationJob
  queue_as :default

  def perform(*args)
    email, token = args
    user = User.find_by(email: email)
    Devise::Mailer.reset_password_instructions(user, token).deliver_now
  end
end
