class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @date = params[:date].present? ? Date.strptime(params[:date], "%Y-%m-%d") : Date.today
    @reports = DailyReport
                .where(created_at: @date.midnight..@date.end_of_day)
                .select("DISTINCT ON(user_id) *")
                .order("user_id, created_at DESC")
  end
end
