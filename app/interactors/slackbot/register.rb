class Slackbot::Register
  include Interactor

  def output(text)
    p text
    context.client.message channel: context.data.channel, text: text
  end

  def call
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

    if db_user = User.find_by(email: email)
      output "Can't register. You are already registered."
      return false
    end

    if pass.blank?
      output "Enter your password."
      context.ready_to_password = true
      return
    end

    if pass.length < 6
      output "Password must have at least 6 symbols."
      return
    end

    db_user = User.new({:email => email, :password => pass, :password_confirmation => pass})
    unless db_user.save
      output "Can't save a new user to DB."
      #context.fail!(error: { })
      return
    end

    output "You have been registered successfully!"
    output "You may reset/restore your password via report web site."
    output "Also it's worth to delete your previous message containing your password."
    context.saved = true
    return
  end

end
