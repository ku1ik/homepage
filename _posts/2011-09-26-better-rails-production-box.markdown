---
title: Better Rails production box
layout: post
tags:
  - deployment
  - rails
  - capistrano
  - logrotate
  - linux
  - nginx
img: http://farm3.static.flickr.com/2735/4245882362\_667c863b3d\_d.jpg
---

Here are 3 simple things to do in order to improve deployment process of your
Rails application and friendliness of your production server. Nothing new here
but many good practices are often overlooked even by experienced developers.

### Set RAILS\_ENV in .bash\_profile

I see my fellow devs typing this on production server all the time:

    script/rails console production

Or this:

    RAILS_ENV=production rake some_task

It's obvious that on production box you want it to run in production
environment, right? Set _RAILS\_ENV_ in _.bash\_profile_ and save your fingers:

    # ~/.bash_profile
    export RAILS_ENV="production"

This might not be the case if your hosting service is like
[Heroku](http://heroku.com) or similar as they export _RAILS\_ENV_ for you
automatically. But if you're on self-managed VPS or
[EC2](http://aws.amazon.com/ec2/) instance you can ease your work with this
trivial setup.

### Use logrotate

Create _/etc/logrotate.d/rails\_logs_ file with following content:

    /var/www/*/shared/log/*.log {
      daily
      missingok
      rotate 30
      compress
      delaycompress
      copytruncate
    }

That will tell [logrotate](http://linuxcommand.org/man_pages/logrotate8.html)
to rotate log files daily, compress them, keep last 30 days and don't choke
when file is missing. _copytruncate_ is important here as it will make sure log
file currently used by Rails app is not moved but truncated. That way the app
can just keep on logging without reopening log file.

Don't forget about this one if you manage production box yourself. And do it
when you initially setup the box, not "later". "Later" often means "when app is
down due to not enough disk space". Srsly.

### Use maintenance page

When deploying with long running or non-trivial (more than add column)
migrations you should use maintenance page of some sort. With capistrano you
can just use (before running migrations):

    cap production deploy:web:disable

and (after they finish):

    cap production deploy:web:enable

Default maintenance page put by capistrano is kind of ugly
so you should make your own matching your site design. In order to do this
prepare _app/views/layouts/maintenance.html.erb_ and override
_deploy:web:disable_ task in _config/deploy.rb_:

    namespace :deploy do
      namespace :web do
        task :disable, :roles => :web do
          require 'erb'
          on_rollback { run "rm #{shared_path}/system/maintenance.html" }

          reason = ENV['REASON']
          deadline = ENV['UNTIL']
          template = File.read('app/views/layouts/maintenance.html.erb')
          page = ERB.new(template).result(binding)

          put page, "#{shared_path}/system/maintenance.html", :mode => 0644
        end
      end
    end

That will put your custom page in _#{shared\_path}/system/maintenance.html_
(also accessible via _public/system/maintenance.html_ by webserver).

On the other end, you should configure webserver to respect presence of this
file. Here is config snippet for [Nginx](http://wiki.nginx.org/):

    server {
      listen 80;
      server_name example.org;
      
      ...
      
      # Maintenance page support
      
      set $maintenance 0;
      
      if (-f $document_root/system/maintenance.html) {
        set $maintenance 1;
      }
      
      if ($request_uri ~* (jpg|jpeg|gif|png|js|css)$) {
        set $maintenance 0;
      }
      
      if ($maintenance) {
        return 503;
      }
      
      error_page 503 @maintenance;
      location @maintenance {
        rewrite ^(.*)$ /system/maintenance.html break;
      }
    }

It will make sure that when _maintenance.html_ file is there Nginx will serve
it and return 503 (Service unavailable) HTTP status. Proper response status is
important here as it gives search engines the message: don't index me now
please, come back later. You don't want your maintenance page get indexed,
do you?

Above Nginx config also allows assets to be served as usual when maintenance
mode is on - especially useful if you don't host them on separate host/subdomain
and you want the page to look nice and match presence of your full site.
