---
title: Rails-like console for any Rack based ruby web app
created_at: 2009-11-15 12:15
tags: racksh, rack, ruby, console, sinatra, merb, rails
markup: markdown

layout: post
---

I always miss script/console from Rails while developing my Sinatra apps, especially ones built with DataMapper where I need to auto-migrate my db. Sinatra doesn't come with any comparable solution as it's not a full framework, but rather library for creating simple web apps. Recently I tried [Heroku](http://heroku.com/) platform and their "heroku console" command inspired me to create something similar - _racksh_ aka _Rack::Shell_.

[racksh](http://github.com/sickill/racksh) is a console for Rack based ruby web applications. It's like Rails' _script/console_ or Merb's _merb -i_, but for any app built on Rack. You can use it to load application environment for Rails, Merb, Sinatra, Camping, Ramaze or your own framework provided there is _config.ru_ file in app's root directory.

It's purpose is to allow developer to introspect his application and/or make some initial setup, ie. running mentioned _DataMapper.auto_migrate!_. It's mainly aimed at apps that don't have similar facility (like Sinatra) but can be used without problems with Merb or Rails apps.

How it works? It loads whole application environment like Rack web server, but it doesn't run the app. Simply, methods like _use_ or _run_ which are normally invoked on Rack::Builder instance are being stubbed.

Instalation is as easy as:

    gem install racksh -s http://gemcutter.org

Then to open console run following inside rack application directory (containing config.ru file):

    racksh

To specify location of config.ru set CONFIG_RU env variable:

    CONFIG_RU=~/projects/foobar/config.ru racksh

Executing ruby code inside application environment and printing results is also supported:

    racksh Order.all
    racksh "Order.first :created_at => Date.today"

Default Rack environment is set to _development_ but it can be changed by setting RACK_ENV env variable:

    RACK_ENV=production racksh

Now I don't need to create some kind of _console.rb_ for my new Rack app, I just use _racksh_. Enjoy!
