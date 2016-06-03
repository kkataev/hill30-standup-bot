json.array!(@teams) do |team|
  json.extract! team, :id, :name, :daily_report
  json.url team_url(team, format: :json)
end
