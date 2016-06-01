class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    if params[:date]
      @date = Date.strptime(params[:date], "%Y-%m-%d")
    else
      @date = Date.today
    end
    @reports = DailyReport.where(created_at: @date.midnight..@date.end_of_day).select([:user_id, :id, :description, 'MAX(created_at)']).group(:user_id, :id)
  end

end
