class Slackbot::Teams

  def self.getTeams(context)
    begin
      teams = Team.all
      if teams.blank?
        Slackbot::Message.send(context, "Error. No teams available.")
        return false
      end
      return teams
    rescue
      Slackbot::Message.send(context, "Error. Can't get teams.")
    end
    return false
  end

  def self.outputList(context)
    teams = self.getTeams(context)
    return false if not teams

    count = 1
    r = ''
    teams.each_with_index do |t, i|
      r = r + '
' +  count.to_s + ' ' + t.name
      count = count + 1
    end

    counter = count > 1 ? '(1 -' + (count - 1).to_s + ') ' : ''
    Slackbot::Message.send context, 'Select team ' + counter + 'from the list: ' + r
    return true
  end

  def self.select(context)
    teams = self.getTeams(context)
    return false if not teams

    team = nil
    begin
      index = Integer(context[:data].text) - 1
      team = teams[index]
      team[:name]
    rescue
      Slackbot::Message.send(context, "Error. Can't get team. Standup canceled.")
      return false
    end

    Slackbot::Message.send(context, 'You selected ' + team[:name] + ' team.')
    return team[:id]
  end

end
