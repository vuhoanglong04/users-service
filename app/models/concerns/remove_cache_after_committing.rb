# frozen_string_literal: true

module RemoveCacheAfterCommitting
  extend ActiveSupport::Concern
  included do
    after_commit :update_data_redis
  end

  private

  def update_data_redis
    UpdateDataRedisJob.perform_later(self.class.name)
  end
end
