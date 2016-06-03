class Slackbot::Report

  def self.save(context, team, report)
    if user = Slackbot::Auth.getAuthenticatedUser(context)
      if result = user.daily_reports.create!({ team_id: team, description: report.to_json })
        Slackbot::Message.send context, "Thank you!"
        return result
      else
        Slackbot::Message.send context, "Sorry, report was not saved."
      end
    end
    return false
  end

end
