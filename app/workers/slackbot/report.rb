class Slackbot::Report

  def self.save(context)
    if user = Slackbot::Auth.getRegisteredUser(context)
      if result = user.daily_reports.create!({ team_id: context[:user][:team], description: context[:user][:report].to_json })
        Slackbot::Message.send context, "Thank you!"
        return result
      else
        Slackbot::Message.send context, "Sorry, report was not saved. DB error."
      end
    else
      Slackbot::Message.send context, "Sorry, report was not saved. Permission denied."
    end
    return false
  end

end
