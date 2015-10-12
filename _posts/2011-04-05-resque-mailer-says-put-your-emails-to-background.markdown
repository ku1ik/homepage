---
title: "Resque Mailer says: Put your emails to background"
layout: post
tags:
  - ruby
  - rails
  - resque
  - gem
---

It's no secret that handling HTTP requests should be quick. Very quick. Your
business' "to be or not to be" may depend on how "fast" is you site. "Fast"
site for end-users is when they're clicking and they don't need to switch to
other tabs to kill time while waiting for page to open.

How to make your site fast?

* buy more RAM (and install Oracle) - it costs $$$
* lazy load what you can after initial page - complicates the code
* do any processing in background - that one is quick win!

Depending on the application there will always be need for some combination of
above. Best practice however, is: __Webserver should not do any heavy data
processing when handling request__. It should just process the request and
return response as soon as possible.

It means that all you can do is:

1. parsing params
2. loading resource(s)
3. changing state of resource(s)
4. _utilizing background processing workers for data grinding_
5. rendering response body from template
6. returning response to client

All of the above steps except last one are optional but they're all usually
required in most apps.  Point 4 is the important here. Developers often forget
about it or are just too lazy to implement it.  But it makes huge difference!
Waiting 10 seconds for page load because the controller needs to finish
something... it's unacceptable.

[Resque](https://github.com/defunkt/resque) to the rescue! Very reliable,
framework independent, fast "Redis-backed library for creating background jobs"
by Github's [defunkt](https://github.com/defunkt). I use various Ruby
web-frameworks to build my webapps, the choice is not always Rails but Resque
can be used with anything.  Good stuff.

Anyway, what is not that common is sending e-mails asynchronously. Yeah, some
people never thought about it.  But sending them right from controller costs.
Building mail message and sending it involves creating lots of ruby objects,
rendering templates, preparing mail headers and eventually passing it to local
MTA or sometimes to remote SMTP server. Sounds like a lot of time, especially
when you use remote SMTP server.

But who would want to create dedicated background worker for this task? Who
would want to enqueue such a job instead of doing simple
`Notifications.signup(@user).deliver` in the controller? Not me.

Enter [ResqueMailer](https://github.com/zapnap/resque_mailer). Originally
created for Rails 2 by [Nick Plante](http://blog.zerosum.org/), updated by me
to work with both Rails 2.x and 3.x. ResqueMailer allows you to move processing
of Rails mailers out of controller to an async Resque worker with minimal fuss.

Just put the gem into your Rails project Gemfile:

    gem 'resque_mailer'

and then include the `Resque::Mailer` module into your Mailer class:

    class Notifications < ActionMailer::Base
      include Resque::Mailer

      def signup(...)
        ...
    end

Instaaant gratification!

This is it. Now start your worker and enjoy faster responses. For information
on ResqueMailer's optional settings see project's
[github repository](https://github.com/zapnap/resque_mailer). For details about setting up
Resque and running workers go to
[README](https://github.com/defunkt/resque/blob/master/README.markdown) of
Resque project.
