---
title: More Rack::Shell goodies for all Rack worshippers
created_at: 2009-11-19 21:03
tags: racksh, rack, ruby, console
---

_Rack::Shell_ got a lot of attention lately and I received some feature requests/ideas from great ruby hackers. [Daniel Neighman](http://github.com/hassox), currently working on [Pancake](http://pancakestacks.wordpress.com/2009/11/19/pancakes-console/), pointed me towards Bryan Helmkamp's [rack-test](http://github.com/brynary/rack-test). This awesome piece of code is now used by _racksh_ to simulate HTTP requests to your Rack application. Yay!

    % racksh
    Rack::Shell v0.9.4 started in development environment.
    >> $rack.get "/"
    => #<Rack::MockResponse:0xb68fa7bc @body="<html>...", @headers={"Content-Type"=>"text/html", "Content-Length"=>"1812"}, @status=200, ...

Check out [README](http://github.com/sickill/racksh/blob/master/README.markdown) for details. Here are just few examples what's possible:

    $rack.get "/", {}, { 'REMOTE_ADDR' => '123.45.67.89' }
    $rack.header "User-Agent", "Firefox"
    $rack.post "/users", :user => { :name => "Jola", :email => "jola@misi.ak" }

Now you can build and test Sinatra apps in single _racksh_ session [like this](http://gist.github.com/239134).

Another nice thing in new version is support for session setup through config files. Rack::Shell supports configuration file _.rackshrc_ which is loaded from two places during startup: user's home dir and application directory (in this order). You can put any ruby code in it, but it's purpose is to setup your session, ie. setting headers which will be used for all $rack.get/post/... requests.

For example to set user agent to Firefox and re-migrate db if loaded environment is _test_ put following in _.rackshrc_:

    # .rackshrc
    
    $rack.header "User-Agent", "Firefox"
    DataMapper.auto_migrate! if $rack.env == "test"
    
You can also make requests in config file:

    # .rackshrc
    
    $rack.put "/signin", :login => "jola", :password => "misiacz"
    
This will ensure you are always logged in when you start _racksh_ :)

Full documentation and sources are on [github](http://github.com/sickill/racksh), gems for all versions on [gemcutter.org](http://gemcutter.org/gems/racksh). Enjoy!

