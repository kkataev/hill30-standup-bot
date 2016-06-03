class Slackbot::Auth

  def self.getEmailFromContext(context)
    email = nil
    begin
      user = context[:webClient].users_info(user: context[:data].user)
      email = user['user']['profile']['email']
    rescue
      Slackbot::Message.send(context, "Error. Can't get an email from context.")
      return false
    end
    return email
  end

  def self.getAuthenticatedUser(context)
    email = self.getEmailFromContext(context)
    return false if email.blank?
    return User.find_by(email: email)
  end

  def self.doRegisterStart(context)
    user = self.getAuthenticatedUser(context)
    if user
      Slackbot::Message.send(context, "Can't register. You are already registered.")
      return false
    end
    return user.nil?
  end

  def self.doRegister(context, password)
    email = self.getEmailFromContext(context)

    return false if(email.blank? or not self.doRegisterStart(context))

    if password.blank?
      Slackbot::Message.send(context, "Enter your password.")
      return
    end
    if password.length < 6
      Slackbot::Message.send(context, "Password must have at least 6 symbols. Enter your password.")
      return
    end

    db_user = User.new({:email => email, :password => password, :password_confirmation => password, enabled: true})
    unless db_user.save
      Slackbot::Message.send(context, "Can't save a new user to DB.")
    end

    Slackbot::Message.send(context, "You have been registered successfully!
You may reset/restore your password via report web site.
Also it's worth to delete your previous message containing your password.")
    return true
  end

end
