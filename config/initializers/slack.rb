Slack.configure do |config|
  config.token = 'xoxb-38890365026-9rhS6WkIQ9erY4BnQ5lp6E5S'
  fail 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
end

Sidekiq.configure_server do |config|
  #config.redis = { url:  "redis://127.0.0.1:6379"}
  SlackWorker.perform_async
end