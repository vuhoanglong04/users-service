# config/initializers/redis.rb
require "redis"

$redis = Redis.new(url: ENV["REDIS_URL"])

