DIR = ::File.expand_path(::File.dirname(__FILE__))
require DIR + "/vendor/gems/environment"
SECRET = ::File.read(DIR + "/.secret").strip rescue ""

require 'sinatra'
require 'run_later'

post "/deploy/:secret" do
  if params["secret"] == SECRET
    run_later do
      `cd #{DIR} && git pull && gem bundle && bin/rake build; mkdir tmp; touch tmp/restart.txt`
    end
    "Thanks, deploying..."
  else
    pass
  end
end

run Sinatra::Application
