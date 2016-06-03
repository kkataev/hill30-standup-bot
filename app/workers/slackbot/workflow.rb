class Slackbot::Workflow

  FIRST_STEP = 'Completed:'
  SECOND_STEP = 'Working on:'
  THIRD_STEP = 'Any problems?'


  def self.doTest(context)
    Slackbot::Message.send context, "Test passed."
  end


  def self.doHelp(context)
    Slackbot::Message.send context, "hill30-standup-bot help:
  -h help
  -r register
  -s start daily report
  -n next report statement"
  end


  def self.doRegister(context)
    if Slackbot::Auth.doRegisterStart context
      context[:user][:ready_to_password] = true
      Slackbot::Message.send context, "Please enter your password."
    end
  end


  def self.doStartReport(context)
    if context[:user]
      context[:user][:started] = true
        Slackbot::Message.send context, "Hi <@#{context[:data].user}>! Lets start the standup! Enter -n to start or go to the next step"
    end
  end


  def self.doNextReportStatement(context)
    if user = context[:user]
      if user[:started] # TODO: Check that daily report already exist
        case user[:current_step]
          when nil then
            Slackbot::Message.send context, FIRST_STEP
            user[:current_step] = FIRST_STEP
          when FIRST_STEP then
            Slackbot::Message.send context, SECOND_STEP
            user[:current_step] = SECOND_STEP
          when SECOND_STEP then
            Slackbot::Message.send context, THIRD_STEP
            user[:current_step] = THIRD_STEP
          when THIRD_STEP then
            if result = Slackbot::Report.save(context, user[:report])
              p result
              user[:started] = false
              user[:current_step] = nil
              user[:report] = {}
            end
        end
      end
    end
  end


  def self.doDefault(context)
    if user = context[:user]
      if user[:ready_to_password]
        if Slackbot::Auth.doRegister context, context[:data].text
          user[:ready_to_password] = false
        end
      end
      if !user[:ready_to_password] && user[:started] && (current_step = user[:current_step])
        user[:report][current_step] = [] if user[:report][current_step].nil?
        user[:report][current_step] << context[:data].text
      end
    end
  end


end
