class RedisCounter
  def self.redis
    @redis ||= Redis.new(url: ENV["REDIS_URL"] || "redis://localhost:6379/0")
  end

  def self.next_chat_number(app_token)
    key = "app:#{app_token}:chat_number"
    redis.incr(key)
  end

  def self.next_message_number(app_token, chat_number)
    key = "app:#{app_token}:#{chat_number}:message_number"
    redis.incr(key)
  end

  # Restore MySQL state into Redis (used at startup or after Redis crash)
  def self.restore_from_db
    Application.find_each do |app|
      redis.set("app:#{app.token}:chat_number", app.chats_count)
      app.chats.find_each do |chat|
        redis.set("app:#{app.token}:#{chat.number}:message_number", chat.messages_count)
      end
    end
  end

  # Sync current Redis counters into MySQL (periodic background job)
  def self.sync_to_db
    Application.find_each do |app|
      chat_key = "app:#{app.token}:chat_number"
      chat_number = redis.get(chat_key).to_i
      if chat_number > app.chats_count
        app.update_column(:chats_count, chat_number)
      end

      app.chats.find_each do |chat|
        message_key = "app:#{app.token}:#{chat.number}:message_number"
        msg_number = redis.get(message_key).to_i
        if msg_number > chat.messages_count
          chat.update_column(:messages_count, msg_number)
        end
      end
    end
  end
end
