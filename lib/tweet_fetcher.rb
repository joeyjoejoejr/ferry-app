require 'twitter'
require "dotenv"
Dotenv.load

class TweetFetcher
  attr_reader :client, :sterr

  def initialize(sterr = STDERR)
    @sterr = sterr
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV.fetch("TWITTER_KEY")
      config.consumer_secret     = ENV.fetch("TWITTER_SECRET")
      config.access_token        = ENV.fetch("TWITTER_ACCESS_TOKEN")
      config.access_token_secret = ENV.fetch("TWITTER_TOKEN_SECRET")
    end
  end

  def fetch(user_name)
    retry_minutes = 0

    begin
      tweets = client.user_timeline(user_name, count: 200)
    rescue
      sterr.print "Retrying: Waiting for #{retry_minutes}\r"
      retry_minutes = 1
      sleep 60
      retry
    end
    sterr.print " " * 30 + "\r"

    max_id = tweets.last.id - 1
    sterr.print "Max ID: #{max_id}\r"

    retry_minutes = 0

    loop do
      begin
        new_tweets = client.user_timeline(user_name, count: 200, max_id: max_id)
      rescue Twitter::Error::TooManyRequests
        sterr.print "Retrying: Waiting for #{retry_minutes}\r"
        sleep 60
        retry
      end

      break if new_tweets.none?
      tweets += new_tweets
      max_id = tweets.last.id - 1
      sterr.print "Max ID: #{max_id}\r"

    end
    tweets.map(&:to_h)
  end
end
