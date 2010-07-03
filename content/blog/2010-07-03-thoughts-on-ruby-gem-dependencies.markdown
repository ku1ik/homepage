---
title: Thoughts on Ruby gem dependencies
created_at: 2010-07-03 11:45
tags: ruby, rubygems, gem
---

### The problem

Having [gem bundler](http://gembundler.com) is great. First, you can forget about gem version collisions (damn you activation errors!). Second, you can forget about manually installing gems on all your machines. Third, you can use git repositories and local directories as gem sources which is neat and is invaluable when working on your own gems. But bundler is a workaround. Yes, it's a workaround for poor rubygems design. Let's look at few examples of the problems I've noticed.

I'll start with [dm-paperclip gem](http://github.com/krobertson/dm-paperclip). Recently I was porting my Merb app to Rails 3 and I've encountered few problems with this little sucker. The biggest headache I had with validations. Note it was fixed recently in dm-paperclip, but makes good example of problem that still exists in relation to other gems. dm-paperclip was doing this:

    ...
    unless defined?(DataMapper::Validate).nil?
    ...

What's the problem here? Let's say you have following lines in your Gemfile:

    gem "dm-validations"
    gem "dm-paperclip"

Looks like everything should work. Wrong! Rails 3 requires all the gems from your Gemfile by calling `Bundler.require Rails.env` but `Bundler.require` doesn't use order of gems specified in Gemfile. For me it first required dm-paperclip and then dm-validations, so when dm-paperclip was being required `DataMapper::Validate` wasn't defined yet. I heard that it may change in future and Bundler will respect the order, to some degree of course. Does this problem lay in bundler or in dm-paperclip? In none of them. Bundler doesn't know about "optional" dependencies of dm-paperclip and dm-paperclip has no way to tell us/bundler it can benefit from some optional lib. 

Anyway, this is good example why explicit requiring of gems seems better in this scenario. By adding `require "this"` and `require "that"` in places where you actually need it you're breaking DRY principle (you already have it in Gemfile) but you can have perfect control of the order. This way you can solve above dm-paperclip problem. And by using explicit requires you can move your app away from bundler (to i.e. [rip](http://github.com/defunkt/rip) or [Isolate](http://github.com/jbarnette/isolate)) if you want to and you don't need to add these requires because they're already in the app. But why would you need to think about gem require order in your Rails app? You shouldn't think about it. And you don't always know what are optional libraries for the gems you're using.

Let's look at second issue. Multiple markdown processing libraries. There's BlueCloth, Maruku, Kramdown, RDiscount, rpeg-markdown and some more. All of them are doing the same thing but the difference is mainly in performance. BlueCloth and Maruku are pure ruby libraries, RDiscount and rpeg-markdown are bindings to fast C libraries. But they all have the same interface:

    BlueCloth.new(markdown_string).to_html          # bluecloth
    Maruku.new(markdown_string).to_html             # maruku
    Kramdown::Document.new(markdown_string).to_html # kramdown
    RDiscount.new(markdown_string).to_html          # rdiscount
    Markdown.new(markdown_string).to_html           # rpeg-markdown

Now, if gem A depends on Maruku and gem B depends on RDiscount I'll have two markdown libraries with identical interface required in my app. I know that RDiscount is faster because it's C and I'd like all of my app's functionalities to use it but gem A will use slower Maruku. Sad but true.

Third rubygems issue is something in the middle between dm-paperclip+bundler problem and markdown problem. [Devise](http://github.com/plataformatec/devise), "Flexible authentication solution for Rails with Warden" supports many ORMs (ActiveRecord, DataMapper, Mongoid). Now, all code related to integration with mentioned ORMs is [included in devise itself](http://github.com/plataformatec/devise/tree/master/lib/devise/orm/). Devise checks which ORM is available at runtime (like in dm-paperclip example) and requires appropriate file choosing from many available alternatives (like in markdown example). It's far from being perfect. How this could be improved? 

It'd be probably better to put integration code in separate gems. This way people involved in development of ORMs could work on integration without access to Devise repository. Yeah, I know, it's not a big deal on github, just fork and send pull request. But it worked really well for dm-rails. DataMapper guys were more interested in getting DM work under Rails 3 than Rails developers and they definitely knew more about DM specifics. They provide the gem and everyone is happy. But if there were many gems providing this functionality for Devise then user would be responsible for installing it. There's better solution on my mind though, read on.

### Possible solutions

To solve first mentioned issue let's just add optional dependencies to rubygems. It could work in following way.

Gem author specifies list of optional dependencies:

    Gem::Specification.new do |s|
      ...
      s.optional_dependency "nokogiri", "for tidying output"
      s.optional_dependency "bar", "for bar support"
    end

You are installing the gem:

    $ gem install foo
    Installed foo.
    Optional dependencies for foo:
    - nokogiri (for tidying output)
    - bar (for bar support)

Or you could install it with optional deps:

    $ gem install foo --with-optional-deps
    Installed nokogiri.
    Installed bar.
    Installed foo.

Benefits of having explicit optional deps would be:

  - user could see what are the optionals and decide if he wants them
  - automatic tools like bundler could be configured to install optional deps, either for all gems or for specific ones
  - bundler could require optional gems before the one which "optionally" depends on them, solving require order issues

To solve second and third issue we can add "provider gems". What's that? Decent Linux package managers like [Archlinux](http://archlinux.org)'s [pacman](http://www.archlinux.org/pacman/) allows you to specify that the package provides the same functionality and the same interface as the other one. In rubygems it could look like this:

Gem authors of all mentioned markdown processors could specify that their gem provides "markdown":

    Gem::Specification.new do |s|
      ...
      s.provides "markdown"
      ...
    end

Additionally they would need to provide unified interface, in this case simple `Markdown = RDiscount` should do the trick.

Now, you as gem user could use it like this:

    require "markdown"
    Markdown.new(markdown_string).to_html

This way gem A and B can depend on "markdown", and you decide which one you want to install. `gem install A` or `bundle install` in this case could show you this:

    $ gem install A
    Gem "A" depends on "markdown". Please select provider gem from following alternatives:
    1. BlueCloth
    2. Maruku
    3. ....

Of course having two "markdown providers" with the same interface (note that `require "markdown"` is also part of the interface) would be impossible in the same gem environment but this can easily be solved by using Bundler, Isolate or [awesome rvm](http://rvm.beginrescueend.com/)'s gemsets. Only problem I see here is when one gem depends on "maruku", not on "markdown", another gem depends on "rdiscount", and your app depends on both of these gems... yuck.

"Provider gems" can be easily applied to Devise's case:

    Gem::Specification.new do |s|
      s.name "devise"
      s.dependency "devise-orm-proxy"
      ...
    end

    Gem::Specification.new do |s|
      s.name "devise-orm-mongoid"
      s.provides "devise-orm-proxy"
      ...
    end

    Gem::Specification.new do |s|
      s.name "devise-orm-dm"
      s.provides "devise-orm-proxy"
      ...
    end

Another example why "provider gems" can be good idea is extlib / AS collision. For example dm-paperclip depends on extlib because it needs inflector. But you can't easily use it in Rails 3 app at the moment because AS+extlib = "UsersesController" :) dm-core used to use extlib for inflections and has been recently converted to AS for some reasons.

"Provider gems" can solve also this problem. Look at this:

    Gem::Specification.new do |s|
      s.name "dm-core"
      s.dependency "inflector"
      ...
    end

    Gem::Specification.new do |s|
      s.name "dm-paperclip"
      s.dependency "inflector"
      ...
    end

    Gem::Specification.new do |s|
      s.name "extlib"
      s.provides "..."
      s.provides "inflector"
      s.provides "..."
    end

    Gem::Specification.new do |s|
      s.name "activesupport"
      s.provides "..."
      s.provides "inflector"
      s.provides "..."
    end

### Conclusion

I realize that these proposed solutions are not ideal and there are some edge cases which need some more thought but maybe it will become a good start for further discussion about the problem. [Rubygems code is on github now](http://github.com/rubygems/rubygems) so we can fork it and improve it!
