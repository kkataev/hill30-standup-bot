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

  data = {
    "Completed:": Faker::Lorem.sentences((0..5).to_a.sample),
    "Working on:": Faker::Lorem.sentences((1..5).to_a.sample),
    "Any problems?": Faker::Lorem.sentences((0..5).to_a.sample)
  }
  user.daily_reports.destroy_all
  user.daily_reports.create!(description: data.to_json, created_at: Date.today-5 )
end
