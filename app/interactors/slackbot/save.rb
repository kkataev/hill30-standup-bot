class Slackbot::Save
  include Interactor

  def call
    if user = User.find_by(email: context.email)
      context.report = user.daily_reports.create!(context.report)
    else
      context.fail!({ message: "You are not registered!" })
    end
  rescue => e
    context.fail!({ message: e.message })
  end

end
