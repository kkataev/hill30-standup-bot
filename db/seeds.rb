# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

unless User.find_by(email: 'admin@example.com')
  User.create!({:email => 'admin@example.com', :password => 'password', :password_confirmation => 'password' })
end

(1..10).each do |i|


user = nil

unless found = User.find_by(email: "test#{i}@example.com")
  user = User.create!({:email => "test#{i}@example.com", :password => 'password', :password_confirmation => 'password', enabled: false })
else
  user = found
end


arr = (1...5).map{ |i| i.to_s 5}


data = {
  "Completed:": arr.drop((0..4).to_a.sample),
  "Working on:": arr.drop((0..4).to_a.sample),
  "Any problems?": arr.drop((0..4).to_a.sample)
}

p data
user.daily_reports.create!(description: data.to_json, created_at: Date.today-5 )

p user

end
