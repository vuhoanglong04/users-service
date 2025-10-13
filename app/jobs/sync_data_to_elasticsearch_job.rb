class SyncDataToElasticsearchJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Post.import(force: true)
    User.import(force: true)
  end
end
