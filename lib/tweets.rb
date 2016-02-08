class Tweets
  include Enumerable
  attr_reader :tweets
  def initialize(tweets)
    @tweets = tweets.map { |tweet| Tweet.new tweet }
  end

  def each(&block)
    tweets.each(&block)
  end
end

class Tweet
  attr_reader :tweet
  def initialize(tweet)
    @tweet = tweet
  end

  def to_event
    {
      ferry: tweet.fetch(:user).fetch(:screen_name),
      twitter_id: tweet.fetch(:id).to_s,
      message: tweet.fetch(:text),
      created_at: tweet.fetch(:created_at),
      event_type: event_type,
      reason: reason
    }
  end

  private

  def event_type
    return "start" if is_start?
    return "stop" if is_stop?
    return "oos" if is_oos?
    "other"
  end

  def is_start?
    start_pattern = /
      ^
      (?:(?!second).)*        # not the second ferry
      (?:
      begun |                 # beginning of day
      began |
      (?:now|currently|is)\sin\sservice |
      currently\soperating |
      (?:has\sgone|will\snow\sbe)\sin\sservice |
      is\soperating |
      (?:will\s*|has)\sbegin |
      resumed |               # Resumed after stopping
      resuming |
      is\sback |
      has\sreturned\sto\snormal
      )
      (?:(?<!second).)*       # not the second ferry
      $
    /ix

    tweet[:text].match start_pattern
  end

  def is_stop?
    stop_pattern = /
      ^
      (?:(?!one\sboat).)*       # Not one boat
      (?:
      concluded |                                           # end of day
      ended |
      (?:out\sof|not\sin|will\snot\sbe\sin)\sservice |      # out of service
      service\sinterruption |
      shut\sdown
      )
    /ix
    tweet[:text].match stop_pattern
  end

  def is_oos?
    parse_oos
  end

  def reason
    if is_oos?
      parse_oos[1] || parse_oos[2] || "No reason given"
    end
  end

  def parse_oos
    reason_pattern = /
      (?:
      due\s(?:to\s)?(?:an?\s)?
      ([\w\s]+)           # reason
      \. |
      out\sof\sservice
      .*
      (?:while\s
      ([\w\s]+)           # reason
      \.
      )
      )
    /ix
    tweet[:text].match reason_pattern
  end
end
