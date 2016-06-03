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
      scheduler.cron '00 10,11,12,14 * * 1-5' do
        User.where(enabled: true).each do |u|
          unless u.daily_reports.where(created_at: Date.today.midnight..Date.today.end_of_day).exists?
            channel = webClient.users_info(user:"@#{u.email.split("@")[0]}")['user']['id']
            p "#{u.email} - #{channel}"
            #if u.email == 'kivanov@hill30.com'
            webClient.chat_postMessage(channel: channel, text: "Time to daily report! #{ HELP_MESSAGE }", as_user: true)
            #end
          end
         end
      end

      scheduler.cron '*/3 * * * *' do
        # TODO: send daily reminder here
        p "ping #{ Time.now }"
      end
    end

    client.on :message do |data|

      p data.user + ": " + data.text

      unless users[data.channel]
        users[data.channel] = {
          ready_to_set_password: false,
          ready_to_select_team: false,
          team: nil,
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

      if context[:user][:ready_to_select_team]
        Slackbot::Workflow.doSelectTeam context
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
