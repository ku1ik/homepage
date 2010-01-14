DIR = ::File.expand_path(::File.dirname(__FILE__))
require DIR + "/vendor/gems/environment"
SECRET = ::File.read(DIR + "/.secret").strip rescue ""

require 'sinatra'

get "/deploy/:secret" do
  if params["secret"] == SECRET
    `cd #{DIR}; bin/rake build; mkdir tmp; touch tmp/restart.txt`
    "OK"
  else
    pass
  end
end

run Sinatra::Application
