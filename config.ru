require "bundler"
Bundler.setup

DIR = ::File.expand_path(::File.dirname(__FILE__))
SECRET = ::File.read(DIR + "/.secret").strip rescue ""

require 'sinatra'
require 'run_later'

post "/deploy/:secret" do
  if params["secret"] == SECRET
    run_later do
      `cd #{DIR}; git pull; bundle exec rake build`
    end
    "Thanks, deploying..."
  else
    pass
  end
end

run Sinatra::Application
