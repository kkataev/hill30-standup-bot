class Slackbot::Register
  include Interactor

  def call

    def output(text)
      puts text
      context.client.message channel: context.data.channel, text: text
    end

    begin
      user = context.webClient.users_info(user: context.data.user)
      email = user['user']['profile']['email']
    rescue
      output "Can't register. Can't get an email from context."
      return false
    end

    if true
      output "Hi <@#{context.data.user}>!
Your email is " + email + ".
You have been registered successfully."
      #context.user = {}
    else
      context.fail!(error: { })
    end
  end
end

# U0RG9ABMW
# <Slack::RealTime::Models::User
# color="a63024" deleted=false id="U0RG9ABMW" is_admin=false is_bot=false is_owner=false is_primary_owner=false
# is_restricted=false is_ultra_restricted=false name="ykononov" presence="away"
# profile=
#   <Slack::Messages::Message avatar_hash="g24c88210f8a" email="ykononov@hill30.com" fields=nil first_name="Юрий"
#   image_192="https://secure.gravatar.com/avatar/24c88210f8ab769f33caf96510243f39.jpg?s=192&d=https%3A%2F%2Fa.slack-edge.com%2F7fa9%2Fimg%2Favatars%2Fava_0015-192.png"
#   image_24="https://secure.gravatar.com/avatar/24c88210f8ab769f33caf96510243f39.jpg?s=24&d=https%3A%2F%2Fa.slack-edge.com%2F66f9%2Fimg%2Favatars%2Fava_0015-24.png"
#   image_32="https://secure.gravatar.com/avatar/24c88210f8ab769f33caf96510243f39.jpg?s=32&d=https%3A%2F%2Fa.slack-edge.com%2F66f9%2Fimg%2Favatars%2Fava_0015-32.png"
#   image_48="https://secure.gravatar.com/avatar/24c88210f8ab769f33caf96510243f39.jpg?s=48&d=https%3A%2F%2Fa.slack-edge.com%2F66f9%2Fimg%2Favatars%2Fava_0015-48.png"
#   image_512="https://secure.gravatar.com/avatar/24c88210f8ab769f33caf96510243f39.jpg?s=512&d=https%3A%2F%2Fa.slack-edge.com%2F7fa9%2Fimg%2Favatars%2Fava_0015-512.png"
#   image_72="https://secure.gravatar.com/avatar/24c88210f8ab769f33caf96510243f39.jpg?s=72&d=https%3A%2F%2Fa.slack-edge.com%2F66f9%2Fimg%2Favatars%2Fava_0015-72.png"
#   last_name="Кононов" real_name="Юрий Кононов" real_name_normalized="Jurij Kononov"> real_name="Юрий Кононов" status=nil team_id="T0QJBTAJ3" tz="Asia/Kuwait"
#   tz_label="Arabia Standard Time" tz_offset=10800>
