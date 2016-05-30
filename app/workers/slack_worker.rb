class SlackWorker

  FIRST_STEP = 'Completed:'
  SECOND_STEP = 'Workin on:'

  include Sidekiq::Worker

  def perform()

    client = Slack::RealTime::Client.new

    report = {}
    current_step = nil
    started = false
    client.on :hello do
      p "Successfully connected, welcome '#{client.self.name}' to the '#{client.team.name}' team at https://#{client.team.domain}.slack.com."
    end

    client.on :message do |data|
      case data.text
        when '-s' then
          client.message channel: data.channel, text: "Hi <@#{data.user}>! Lets start the standup! Enter -n to start or go to the next step"
          started = true
        when '-n' then
          case current_step
            when nil then
              client.message channel: data.channel, text: FIRST_STEP
              current_step = FIRST_STEP
            when FIRST_STEP then
              client.message channel: data.channel, text: SECOND_STEP
              current_step = SECOND_STEP
            when SECOND_STEP then
              client.message channel: data.channel, text: "Thank you!"
              started = false
              report.each do |header, messages|
                p header
                messages.each do |message|
                  p "- #{ message }"
                end
              end
          end
        else
          p data.text
          if started && current_step
            if started
              report[current_step] = [] if report[current_step].nil?
              report[current_step] << data.text
            end
          end
      end
    end

    client.on :close do |_data|
      puts "Client is about to disconnect"
    end

    client.on :closed do |_data|
      puts "Client has disconnected successfully!"
    end

    client.start!

  end
end
