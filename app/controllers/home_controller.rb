class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @reports = DailyReport.select([:user_id, :id, :description, 'MAX(created_at)']).group(:user_id)
  end

end
