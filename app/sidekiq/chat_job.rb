class ChatJob
  include Sidekiq::Job
  sidekiq_options queue: :realtime, retry: 3

  def perform(application_token, chat_number)
    app = Application.find_by(token: application_token)
    return unless app


    chat = app.chats.create!(
      number: chat_number
    )

    Rails.logger.info "Chat created for app #{application_token} Chat ##{chat.number}"
  end
end
