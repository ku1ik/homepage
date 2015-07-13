---
title: Rails is half of your application
layout: post
tags:
  - rails
  - ruby
---

Only a week ago [I was still standing
strong](https://twitter.com/sickill/status/440885912625766400) behind the
"Rails is not your application" statement. It felt natural to me and I haven't
bothered to think deeper about it. Since then I discussed this topic with
several people and I read [Domain Logic in
Rails](http://www.smashingboxes.com/domain-logic-in-rails/) by Reed Law which
mentions DHH's and Uncle Bob's differing approaches to building applications. A
torrent of thoughts hit me then and I realized the truth lays somewhere in
between. I started analyzing the subject deeper and this article is my attempt
to explain what your application actually is and where it stands in relation to
"Rails application" label.

Let's first find out what different types of code we put in the application.
What does a Rails app directory contain?  When you run `rails new` you get
several directories created for you - your Rails app structure.  Three most
interesting directories are `app`, `lib` and `config`. You put your controllers
to `app/controller`, views to `app/views`. You configure your routes in
`config/routes.rb`. The business logic goes to `app/models`, `app/services` and
to some other directories under `app` or `lib`. Many people still put it into
controllers though.

We can group entities contained in the mentioned directories in two groups:
things that can be used outside of Rails application, and things that cannot.
Your domain logic, services and models fall into the first group. Controllers,
views, helpers and routes fall into the second group. And no, putting entities
from the second group into a Rails engine (and making a gem out of it) is not
the way of re-use I'm talking about - this engine can't be used in let's say an
iOS app, right? Sounds obvious, but bear with me.

What this means is that you can reuse business logic (backend) but you can't
reuse the UI (frontend). You don't actually want to reuse the frontend. How
likely it is that you will need your routes, controllers and views in another
app? Unlikely. You just build another UI, be it a mobile, html5/js, or a
desktop app. So Rails is your frontend. In fact it's a business logic delivery
mechanism. You have chosen Rails to be on the frontline, to serve the most user
facing duty of your business.

Let's say you actually want to build another application to use the existing
business logic. We know it's possible, so you extract the logic into a gem or a
separate ruby application that is an API (Sinatra or rails-api). When
extracting your business logic into an API you still need to access it - thin
adapter(s) used from the controllers can do the job. Now your original app
becomes only the UI. A "UI application", "frontend application" or just "one of
the applications using your API/gem". As a matter of fact the code that is now
left in `app/*` means nothing outside of Rails app. Think about it. Also, what
stands after `run` in your `config.ru` file?  `Rails::Application`. It's your
own flavor of it (you inherit from it) but it's still a `Rails::Application`.
When you start a server Rails boots and your code in `app/*` and `config/*`
just fills some slots in the Rails app. Not the other way around! Your code
doesn't use Rails - Rails uses your code. Can we say then that Rails is your
application? It may be more fair to say that Rails is your application runtime.
It runs your application and provides many facilities to it. Anyway, if you
don't like that idea then there are some nice new Ruby web frameworks emerging
([Lotus](http://lotusrb.org/), [Pakyow](http://pakyow.com/)).

We can look at it from a slightly different perspective. In reality most Rails
apps serve both purposes. They provide the UI and domain logic at the same
time, keeping both under the same source code tree. The number of Rails apps
that don't implement any business logic themselves is pretty damn low.
Regardless of where the business logic technically sits, we have the Rails
dependent part (UI) and the Rails independent part (logic). Can we say that
Rails dependent part, together with Rails itself is one half of your
application and the logic part the second half? I think we can. Some developers
believe that only the part of the code that is below the controllers (services
and models) is "the application". Is it really the case? What's worth your
"application" without the UI? What do you think?

In the next post I'm going to find out where the exact line between those parts
goes (hint hint: controller) and how we can pull this line to our side to
maximize benefits (where should the authorization go? where should the
loading/building of models happen? Why ActiveSupport can invisibly make your
domain logic Rails dependent?) 
