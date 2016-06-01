class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    if params[:date]
      @date = Date.strptime(params[:date], "%Y-%m-%d")
    else
      @date = Date.today
    end
    @reports = DailyReport.where(created_at: @date.midnight..@date.end_of_day).select("DISTINCT ON(user_id) *").order("user_id, created_at DESC")
  end

end
