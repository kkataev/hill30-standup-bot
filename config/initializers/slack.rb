Slack.configure do |config|
  config.token = 'xoxb-40730681238-fus1sAETbgJF1vKh917uUxJp'
  fail 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
end

Sidekiq.configure_server do |config|
  #config.redis = { url:  "redis://127.0.0.1:6379"}
  SlackWorker.perform_async
end
