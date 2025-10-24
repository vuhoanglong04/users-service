class SyncDataToElasticsearchJob < ApplicationJob
  queue_as :default

  def perform(*args)
    User.import(force: true)
  end
end
