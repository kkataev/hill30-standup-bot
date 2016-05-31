class Slackbot::Register
  include Interactor

  def call
    p context
    if true
      context.client.message channel: context.data.channel, text: "Hi <@#{context.data.user}>! You have been registered."
      #context.user = {}
    else
      context.fail!(error: { })
    end
  end
end
