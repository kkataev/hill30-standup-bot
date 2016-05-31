Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN'] #'xoxb-40730681238-fus1sAETbgJF1vKh917uUxJp'
  p config.token
  fail 'Missing ENV[SLACK_API_TOKEN]!' unless config.token

  Slack::RealTime.configure do |config|
    config.concurrency = Slack::RealTime::Concurrency::Eventmachine
  end

end
