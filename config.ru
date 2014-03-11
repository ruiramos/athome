require 'bundler'
Bundler.require

require './athome.rb'

# Make sinatra play nice
set :env, :production
disable :run, :reload

app = Rack::Builder.new {
  # Anything urls starting with /tiny will go to Sinatra
  map "/api" do
		run AtHome
  end

  # Push Notifications
  map "/" do
    run Rack::PushNotification
  end
}.to_app

#Rack::Handler::Thin.run app
run app