set :output, File.expand_path("../../log/cron_log.log", __FILE__)
env :PATH, ENV["PATH"]
env :GEM_PATH, ENV["GEM_PATH"]

every 1.day, at: "6:00 pm" do
  rake "bigquery:atualizar"
end
