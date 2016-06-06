class Slackbot::Report

  def self.save(context)
    if user = Slackbot::Auth.getAuthenticatedUser(context)
      if result = user.daily_reports.create!({ team_id: context[:user][:team], description: context[:user][:report].to_json })
        Slackbot::Message.send context, "Thank you!"
        return result
      else
        Slackbot::Message.send context, "Sorry, report was not saved."
      end
    end
    return false
  end

end
