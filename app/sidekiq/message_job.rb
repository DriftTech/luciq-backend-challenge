class MessageJob
  include Sidekiq::Job
  sidekiq_options queue: :realtime, retry: 3

  def perform(application_token, chat_number, body, message_number)
    app = Application.find_by(token: application_token)
    return unless app

    chat = app.chats.find_by(number: chat_number)
    return unless chat

    message = chat.messages.find_or_initialize_by(number: message_number)
    message.body = body
    message.save!

    message.__elasticsearch__.index_document

    Rails.logger.info "Message processed for app #{application_token}, chat ##{chat_number}, Message ##{message.number}"
  end
end
