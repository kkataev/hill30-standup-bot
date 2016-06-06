class Slackbot::Workflow

  FIRST_STEP = 'What has been done? (-n to next statement)'
  SECOND_STEP = 'What are you working on? (-n to next statement)'
  THIRD_STEP = 'Any problems? (-n to finish)'
  HELP_MESSAGE = 'hill30-standup-bot help:
  -h help
  -r register
  -s start daily report
  -n next report statement'


  def self.doTest(context)
    Slackbot::Message.send context, "Test passed."
  end


  def self.doHelp(context)
    Slackbot::Message.send context, HELP_MESSAGE
  end


  def self.doRegister(context)
    if Slackbot::Auth.doRegisterStart context
      context[:user][:ready_to_set_password] = true
      Slackbot::Message.send context, "Please enter your password."
    end
  end


  def self.doStartReport(context)
    if user = context[:user]
      user[:started] = true
        Slackbot::Message.send context, "Hi <@#{context[:data].user}>! Lets start the standup!"
        if Slackbot::Teams.outputList context
          user[:ready_to_select_team] = true
        end
    end
  end


  def self.doNextReportStatement(context)
    if user = context[:user]
      if user[:started] # TODO: Check that daily report already exist
        case user[:current_step]
          when FIRST_STEP then
            Slackbot::Message.send context, SECOND_STEP
            user[:current_step] = SECOND_STEP
          when SECOND_STEP then
            Slackbot::Message.send context, THIRD_STEP
            user[:current_step] = THIRD_STEP
          when THIRD_STEP then
            if result = Slackbot::Report.save(context)
              p result
              user[:started] = false
              user[:current_step] = nil
              user[:report] = {}
            end
        end
      end
    end
  end


  def self.doSetPassword(context)
    if user = context[:user]
      if Slackbot::Auth.doRegister context
        user[:ready_to_set_password] = false
      end
    end
  end


  def self.doSelectTeam(context)
    if user = context[:user]
       if team = Slackbot::Teams.select(context)
         user[:team] = team
         user[:current_step] = FIRST_STEP
         Slackbot::Message.send context, FIRST_STEP
         user[:ready_to_select_team] = false
         user[:current_step] = FIRST_STEP
       end
    end
  end


  def self.doDefault(context)
    if user = context[:user]
      if user[:started] && (current_step = user[:current_step])
        user[:report][current_step] = [] if user[:report][current_step].nil?
        user[:report][current_step] << context[:data].text
      end
    end
  end


end
