Rails.application.config.after_initialize do
  Thread.new do
    begin
      Rails.logger.info "Restoring Redis counters from database..."
      RedisCounter.restore_from_db
      Rails.logger.info "Redis counters restored"
    rescue => e
      Rails.logger.error "Failed to restore Redis counters: #{e.message}"
    end
  end
end
