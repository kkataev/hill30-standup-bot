class Slackbot::Message

  def self.send(context, text, console = true, channel = true)
    p text if console
    if channel
      context[:client].message channel: context[:data].channel, text: text
    end
  end

end
