class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @date = params[:date].present? ? Date.strptime(params[:date], "%Y-%m-%d") : Date.today
    team = params[:team].present? && params[:team].to_i > 0 ? params[:team].to_i : nil
    @teams = Team.all
    @team = team ? @teams.find(team) : nil
    @reports = @team.blank? ? nil : DailyReport
                .where(team_id: @team, created_at: @date.midnight..@date.end_of_day)
                .select("DISTINCT ON(user_id) *")
                .order("user_id, created_at DESC")
  end
end
