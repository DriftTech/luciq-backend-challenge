class Message < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  belongs_to :chat

  validates :body, presence: true
  validates :number, presence: true, uniqueness: { scope: :chat_id }

  index_name "messages_#{Rails.env}"

  settings do
    mappings dynamic: "false" do
      indexes :body, type: :text, analyzer: :ngram_analyzer
      indexes :chat_number, type: :integer
      indexes :application_token, type: :keyword
    end
  end

  settings index: {
    max_ngram_diff: 18,
    analysis: {
      analyzer: {
        ngram_analyzer: {
          type: "custom",
          tokenizer: "ngram_tokenizer",
          filter: [ "lowercase" ]
        }
      },
      tokenizer: {
        ngram_tokenizer: {
          type: "ngram",
          min_gram: 2,
          max_gram: 20,
          token_chars: [ "letter", "digit" ]
        }
      }
    }
  }

  def as_indexed_json(_options = {})
    {
      body: body,
      chat_number: chat.number,
      application_token: chat.application.token
    }
  end
end
