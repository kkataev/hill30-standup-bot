class AddTeamRefToDailyReports < ActiveRecord::Migration
  def change
    add_reference :daily_reports, :team, index: true, foreign_key: true
  end
end
