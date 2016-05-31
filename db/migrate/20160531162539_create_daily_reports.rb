class CreateDailyReports < ActiveRecord::Migration
  def change
    create_table :daily_reports do |t|
      t.integer :user_id
      t.text :description
      
      t.timestamps null: false
    end
  end
end
