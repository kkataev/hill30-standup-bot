require 'rufus-scheduler'

class SlackWorker
  include Sidekiq::Worker

  sidekiq_options queue: "slack"

  def perform()
    client = Slack::RealTime::Client.new
    webClient = Slack::Web::Client.new
    scheduler = Rufus::Scheduler.new

    users = {}

    client.on :hello do
      p "Successfully connected, welcome '#{client.self.name}' to the '#{client.team.name}' team at https://#{client.team.domain}.slack.com."
      # right now set to every minute
      # for example every working day at 15:30 will be 30 15 * * 1-5
      #scheduler.cron '20 16 * * 1-5' do
      scheduler.cron '* * * * *' do
        # TODO: send daily reminder here
        p Time.now
        p 'Hello... Rufus'
      end
    end

    client.on :message do |data|

      p data.user + ": " + data.text

      unless users[data.channel]
        users[data.channel] = {
          ready_to_set_password: false,
          ready_to_select_team: false,
          started: false,
          current_step: nil,
          report: {}
        }
      end

      context = { client: client, webClient: webClient, data: data, user: users[data.channel] }

      if context[:user][:ready_to_set_password]
        Slackbot::Workflow.doSetPassword context
        next
      end

      case data.text
        when '-t' then Slackbot::Workflow.doTest context
        when '-h' then Slackbot::Workflow.doHelp context
        when '-r' then Slackbot::Workflow.doRegister context
        when '-s' then Slackbot::Workflow.doStartReport context
        when '-n' then Slackbot::Workflow.doNextReportStatement context
        else Slackbot::Workflow.doDefault context
      end

    end

    client.on :close do |_data|
      p "Client is about to disconnect"
    end

    client.on :closed do |_data|
      p "Client has disconnected successfully!"
    end

    client.start_async
  end
end
