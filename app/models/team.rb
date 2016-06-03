class Team < ActiveRecord::Base
  has_many :daily_reports
end
