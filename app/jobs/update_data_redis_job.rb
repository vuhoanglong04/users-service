class UpdateDataRedisJob < ApplicationJob
  queue_as :default

  def perform(model_name)
    pattern = "#{model_name.downcase}_page*"
    keys = $redis.keys(pattern)
    keys.each { |key| $redis.del(key) }
  end
end
