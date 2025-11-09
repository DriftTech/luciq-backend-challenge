class MessagesController < ApplicationController
  before_action :set_chat
  before_action :set_message, only: [ :show, :update ]


  def index
    messages = Rails.cache.fetch(cache_key, expires_in: 2.minutes) do
      @chat.messages.to_a
    end
    render json: messages.as_json(only: [ :number, :body ])
  end

  def show
    render json: @message.as_json(only: [ :number, :body ])
  end


  def update
    if @message.update(message_params)
      MessageJob.perform_async(@chat.application.token, @chat.number, @message.body, @message.number)
      Rails.cache.delete(cache_key)
      render json: @message.as_json(only: [ :number, :body ]), status: :ok
    else
      render json: { errors: @message.errors.full_messages }, status: :unprocessable_entity
    end
  end


  def create
    token = params[:application_token]
    chat_number = params[:chat_number]
    body = params[:body]
    message_number = RedisCounter.next_message_number(token, chat_number)
    MessageJob.perform_async(token, chat_number, body, message_number)
    render json: { message_number: message_number }, status: :accepted
  end

  def search
    token = params[:application_token]
    chat_number = params[:chat_number]
    query = params[:q]

    if query.blank?
      render json: { error: "Query cannot be empty" }, status: :bad_request
      return
    end

    results = Message.search({
      query: {
        bool: {
          must: [
            { match: { body: query } },
            { term: { application_token: token } },
            { term: { chat_number: chat_number.to_i } }
          ]
        }
      }
    })

    messages = results.records.map do |msg|
      msg.as_json(only: [ :number, :body ])
    end

    render json: messages, status: :ok
  end

  private

  def set_chat
    app = Application.find_by!(token: params[:application_token])
    @chat = app.chats.find_by!(number: params[:chat_number])
  end

  def message_params
    params.require(:message).permit(:body)
  end

  def set_message
    @message = @chat.messages.find_by!(number: params[:number])
  end

  def cache_key
    "messages/#{params[:application_token]}/#{params[:chat_number]}"
  end
end
