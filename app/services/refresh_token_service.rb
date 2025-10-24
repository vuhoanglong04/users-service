# frozen_string_literal: true

class RefreshTokenService
  REDIS_NAMESPACE = "RF"

  def self.issue(user_id)
    token = SecureRandom.hex(64)
    $redis.set("#{REDIS_NAMESPACE}:#{token}", user_id, ex: 30.days.to_i)
    token
  end

  def self.verify(token)
    user_id = $redis.get("#{REDIS_NAMESPACE}:#{token}")
    user_id
  end

  def self.rotate(old_token, user_id)
    $redis.del("#{REDIS_NAMESPACE}:#{old_token}")
    issue(user_id)
  end

  def self.revoke(token)
    $redis.del("#{REDIS_NAMESPACE}:#{token}")
  end
end
