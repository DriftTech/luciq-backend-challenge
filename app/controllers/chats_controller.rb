class ChatsController < ApplicationController
  before_action :set_application

  def index
    render json: @application.chats.as_json(only: [ :number ])
  end

  def show
    chat = @application.chats.find_by!(number: params[:number])
    render json: chat.as_json(only: [ :number ])
  end

  def create
    token = params[:application_token]
    chat_number = RedisCounter.next_chat_number(token)
    ChatJob.perform_async(token, chat_number)
    render json: { chat_number: chat_number }, status: :accepted
  end

  private

  def set_application
    @application = Application.find_by!(token: params[:application_token])
  end
end
