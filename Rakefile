require "dotenv"
Dotenv.load
require "sequel"
require "json"
require "./lib/tweets"
require "./lib/tweet_fetcher"
require "byebug"


namespace :db do
  desc "Run migrations"
  task :migrate, [:version] do |t, args|
    Sequel.extension :migration
    db = Sequel.connect(ENV.fetch("DATABASE_URL"))
    if args[:version]
      puts "Migrating to version #{args[:version]}"
      Sequel::Migrator.run(db, "db/migrations", target: args[:version].to_i)
    else
      puts "Migrating to latest"
      Sequel::Migrator.run(db, "db/migrations")
    end
  end

  desc "Load ferry records"
  task :load, [:ferry_file] do |_, args|
    tweets = JSON.parse File.read(args[:ferry_file]), symbolize_names: true
    db = Sequel.connect(ENV.fetch("DATABASE_URL"))
    ferries = db[:ferries]
    events = db[:events]

    Tweets.new(tweets).each do |tweet|
      event = tweet.to_event
      ferry_name = event.delete :ferry

      unless ferry = ferries.where(name: ferry_name).first
        puts "creating ferry: #{ferry_name}"
        ferries.insert(name: ferry_name)
        ferry = ferries.where(name: ferry_name).first
      end
      event[:ferry_id] = ferry[:id]

      unless events.where(twitter_id: event[:twitter_id]).any?
        puts "creating event: #{event[:twitter_id]}"
        events.insert event
      end
    end
  end

  task :load_new do
    fetcher = TweetFetcher.new
    tweets = fetcher.fetch("Canal_Ferry") + fetcher.fetch("Chalmette_Ferry")
    db = Sequel.connect(ENV.fetch("DATABASE_URL"))
    ferries = db[:ferries]
    events = db[:events]

    Tweets.new(tweets).each do |tweet|
      event = tweet.to_event
      ferry_name = event.delete :ferry

      unless ferry = ferries.where(name: ferry_name).first
        puts "creating ferry: #{ferry_name}"
        ferries.insert(name: ferry_name)
        ferry = ferries.where(name: ferry_name).first
      end
      event[:ferry_id] = ferry[:id]

      unless events.where(twitter_id: event[:twitter_id]).any?
        puts "creating event: #{event[:twitter_id]}"
        events.insert event
      end
    end
  end

  task :dump do
    sh "pg_dump --no-owner --no-acl #{ENV.fetch("DATABASE_URL")} | gzip >> db/dump.sql.gz"
  end

  task :restore do
    sh "gunzip -c db/dump.sql.gz | psql #{ENV.fetch("DATABASE_URL")}"
  end
end
