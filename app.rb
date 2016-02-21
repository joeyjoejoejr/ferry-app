require "sinatra/base"
require "sinatra/namespace"
require "sinatra/json"
require "sinatra/reloader"
require "sequel"
require 'date'

module FerryApp
  class App < Sinatra::Base
    DB = Sequel.connect ENV.fetch("DATABASE_URL")
    register Sinatra::Namespace

    configure :development do
      register Sinatra::Reloader
    end

    get "/" do
      erb :"index.html"
    end

    namespace '/api' do
      get "/events" do
        dataset = DB[:events]
        results = dataset
          .select(
            :events__id,
            :name___ferry_name,
            :event_type,
            :message,
            :reason,
            :twitter_id,
            :created_at
          )
          .join(:ferries, id: :ferry_id)
          .reverse_order(:created_at)
          .where{ created_at >= (DateTime.now << 1)}
        p results.sql
        json data: results.all
      end
    end
  end
end
