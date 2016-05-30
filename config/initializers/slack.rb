Slack.configure do |config|
  config.token = 'xoxb-46720370647-ZNplrdBKuPDd4xzd2hv5zzQh'
  fail 'Missing ENV[SLACK_API_TOKEN]!' unless config.token

  Slack::RealTime.configure do |config|
    config.concurrency = Slack::RealTime::Concurrency::Eventmachine
  end

end
