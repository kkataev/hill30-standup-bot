require 'rufus-scheduler'

class SlackWorker
  include Sidekiq::Worker

  sidekiq_options queue: "slack"

  FIRST_STEP = 'Completed:'
  SECOND_STEP = 'Workin on:'
  THIRD_STEP = 'Any problems?'

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
        p 'Hello... Rufus'
        p Time.now
      end
    end

    client.on :message do |data|

      unless users[data.channel]
        users[data.channel] = {
          ready_to_password: false,
          started: false,
          current_step: nil,
          report: {}
        }
      end

      p users

      current_user = users[data.channel]

      case data.text
        when '-h' then
          client.message channel: data.channel, text: "hill30-standup-bot help:
  -h help
  -r register
  -s start daily report
  -n next report statement"
        when '-s' then
          if current_user
            current_user[:started] = true
            client.message channel: data.channel, text: "Hi <@#{data.user}>! Lets start the standup! Enter -n to start or go to the next step"
          end
        when '-r' then
          result = Slackbot::Register.call({ client: client, webClient: webClient, data: data })
          if result.ready_to_password
            current_user[:ready_to_password] = true
          end
        when '-n' then
          if current_user
            if current_user[:started] # TODO: Check that daily report already exist
              case current_user[:current_step]
                when nil then
                  client.message channel: data.channel, text: FIRST_STEP
                  current_user[:current_step] = FIRST_STEP
                when FIRST_STEP then
                  client.message channel: data.channel, text: SECOND_STEP
                  current_user[:current_step] = SECOND_STEP
                when SECOND_STEP then
                  client.message channel: data.channel, text: THIRD_STEP
                  current_user[:current_step] = THIRD_STEP
                when THIRD_STEP then
                  client.message channel: data.channel, text: "Thank you!"
                  # TODO: put report into DB here
                  user = webClient.users_info(user: data.user)
                  p user['user']['profile']['email']

                  resp = Slackbot::Save.call({
                    email: user['user']['profile']['email'],
                    report: {
                      description: current_user[:report].to_json
                    }
                  })
                  p resp
                  current_user[:started] = false
                  current_user[:current_step] = nil
                  current_user[:report] = {}
              end
            end
          end
        else
          if current_user
            if current_user[:ready_to_password]
              result = Slackbot::Register.call({ client: client, webClient: webClient, data: data, password: data.text })
              if result.saved
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
