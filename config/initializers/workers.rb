Sidekiq.configure_server do |config|
  SlackWorker.perform_async
end
