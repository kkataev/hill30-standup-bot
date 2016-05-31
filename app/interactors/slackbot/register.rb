class Slackbot::Register
  include Interactor

  def call

    def output(text)
      puts text
      context.client.message channel: context.data.channel, text: text
    end

    user = nil
    email = nil
    name = context.data.user
    pass = context.password

    begin
      user = context.webClient.users_info(user: context.data.user)
      email = user['user']['profile']['email']
    rescue
      output "Can't register. Can't get an email from context."
      return false
    end

    dbUser = User.find_by(email: email)
    if dbUser
      output "Can't register. You are already registered."
      return false
    end

    if pass.blank?
      output "Enter your password."
      context.readyToPassword = true
      return
    end

    if pass.length < 6
      output "Password must have at least 6 symbols."
      return
    end

    dbUser = User.new({:email => email, :password => pass, :password_confirmation => pass})
    unless dbUser.save
      output "Can't save a new user to DB."
      #context.fail!(error: { })
      return
    end

    output "You have been registered successfully!"
    context.saved = true
    return

  end
end
