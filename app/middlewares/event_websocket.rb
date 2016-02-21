require "faye/websocket"
require "redis"

module FerryApp
  class EventWebsocket
    KEEPALIVE_TIME = 15
    CHANNEL = "ferry-app"

    attr_reader :clients, :app, :redis

    def initialize(app)
      @app = app
      @clients = []
      @redis = Redis.new
      redis.ping
      Thread.new do
        redis_sub = Redis.new
        redis_sub.subscribe(CHANNEL) do |on|
          on.message do |_channel, msg|
            clients.each { |ws| ws.send msg }
          end
        end
      end
    end

    def call(env)
      if Faye::WebSocket.websocket? env
        ws = Faye::WebSocket.new env, nil, ping: KEEPALIVE_TIME

        ws.on :open do |event|
          p [:open, ws.object_id]
          @clients << ws
        end

        ws.on :message do |event|
          p [:message, event.data]
          redis.publish CHANNEL, event.data
        end

        ws.on :close do |event|
          p [:close, ws.object_id, event.code, event.reason]
          clients.delete ws
          ws = nil
        end

        ws.rack_response
      else
        app.call env
      end
    end
  end
end
