# app/workers/redis_sync_worker.rb
class RedisSyncJob
  include Sidekiq::Job
  sidekiq_options queue: :sync, retry: 3

  def perform
    Rails.logger.info "Starting Redis to MySQL counter sync..."
    RedisCounter.sync_to_db
    Rails.logger.info "Redis to MySQL sync complete"
  end
end
