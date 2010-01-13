require "sinatra"

SECRET = ::File.read(::File.dirname(__FILE__) + "/../.secret").strip rescue ""

post "/deploy/:secret" do
  if params["secret"] == SECRET
    # git pull
    # nanoc compile
  else
    pass
  end
end

run Sinatra::Application

