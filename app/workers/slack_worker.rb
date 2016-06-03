require 'rufus-scheduler'

class SlackWorker
  include Sidekiq::Worker

  sidekiq_options queue: "slack"

  FIRST_STEP = 'Completed:'
  SECOND_STEP = 'Working on:'
  THIRD_STEP = 'Any problems?'
  HELP_MESSAGE = 'hill30-standup-bot help:
-h help
-r register
-s start daily report
-n next report statement'

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
          ready_to_password: false,
          started: false,
          current_step: nil,
          report: {}
        }
      end

      current_user = users[data.channel]
      context = { client: client, webClient: webClient, data: data }

      case data.text
        when '-h' then
          Slackbot::Message.send context, HELP_MESSAGE
        when '-t'
          Slackbot::Message.send context, "Test passed."
        when '-s' then
          if current_user
            current_user[:started] = true
              Slackbot::Message.send context, "Hi <@#{data.user}>! Lets start the standup! Enter -n to start or go to the next step"
          end
        when '-r' then
          if Slackbot::Auth.doRegisterStart context
            current_user[:ready_to_password] = true
            Slackbot::Message.send context, "Please enter your password."
          end
        when '-n' then
          if current_user
            if current_user[:started] # TODO: Check that daily report already exist
              case current_user[:current_step]
                when nil then
                  Slackbot::Message.send context, FIRST_STEP
                  current_user[:current_step] = FIRST_STEP
                when FIRST_STEP then
                  Slackbot::Message.send context, SECOND_STEP
                  current_user[:current_step] = SECOND_STEP
                when SECOND_STEP then
                  Slackbot::Message.send context, THIRD_STEP
                  current_user[:current_step] = THIRD_STEP
                when THIRD_STEP then
                  if result = Slackbot::Report.save(context, current_user[:report])
                    p result
                    current_user[:started] = false
                    current_user[:current_step] = nil
                    current_user[:report] = {}
                  end
              end
            end
          end
        else
          if current_user
            if current_user[:ready_to_password]
              if Slackbot::Auth.doRegister context, data.text
                current_user[:ready_to_password] = false
              end
            end
            if !current_user[:ready_to_password] && current_user[:started] && (current_step = current_user[:current_step])
              current_user[:report][current_step] = [] if current_user[:report][current_step].nil?
              current_user[:report][current_step] << data.text
            end
          end
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
