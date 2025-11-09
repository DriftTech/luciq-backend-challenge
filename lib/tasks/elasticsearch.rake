namespace :elasticsearch do
  desc "Reindex all existing Messages into Elasticsearch"
  task reindex_messages: :environment do
    puts "Reindexing messages for environment: #{Rails.env}"

    Message.__elasticsearch__.create_index! force: true
    Message.import

    puts "All messages have been reindexed into Elasticsearch."
  end
end
