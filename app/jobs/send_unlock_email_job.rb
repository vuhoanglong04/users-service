class SendUnlockEmailJob < ApplicationJob
  queue_as :default

  def perform(user, token)

  end
end
