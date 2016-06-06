
### Teams creation ###

teams_amount = 3

(1..teams_amount).each do |i|
  team = nil

  if found = Team.find_by(name: "Test Team №#{i}")
    team = found
  else
    team = Team.create!({
      :name => "Test Team №#{i}"
    })
  end
end

### Users creation ###

unless User.find_by(email: 'admin@example.com')
  User.create!({
    :email => 'admin@example.com',
    :password => 'password',
    :password_confirmation => 'password'
  })
end

(1..10).each do |i|
  user = nil

  if found = User.find_by(email: "test#{i}@example.com")
    user = found
  else
    user = User.create!({
      :email => "test#{i}@example.com",
      :password => 'password',
      :password_confirmation => 'password'
    })
  end

  ### Reports creation ###

  data = {
    "0": Faker::Lorem.sentences((0..5).to_a.sample),
    "1": Faker::Lorem.sentences((1..5).to_a.sample),
    "2": Faker::Lorem.sentences((0..5).to_a.sample)
  }
  user.daily_reports.destroy_all
  user.daily_reports.create!(team_id: rand(1..teams_amount), description: data.to_json, created_at: Date.today-5 )

end
