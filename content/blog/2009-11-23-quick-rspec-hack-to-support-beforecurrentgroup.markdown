---
title: Quick RSpec hack to support before(:current_group)
created_at: 2009-11-23 00:41
tags: ruby, rspec, testing
markup: markdown

layout: post
---

The problem is described [here](http://www.ruby-forum.com/topic/177609), [here](https://rspec.lighthouseapp.com/projects/5645/tickets/819-beforeall-executes-multiple-times-with-nested-example-groups), [here](https://rspec.lighthouseapp.com/projects/5645/tickets/632) and [here](http://www.swombat.com/getting-rspec-beforeall-and-nested-contexts-w) (this one is crazy!).

First, save following code in spec/before_current_group.rb:

    $_groups = []

    class Spec::Runner::Configuration
      alias_method :old_before, :before
      def before(what, &blk)
        if what == :current_group
          before(:all) do
            top_level_group = self.class.to_s[/^.+ExampleGroup::([^:]+)/, 1]
            unless $_groups.any? { |g| top_level_group == g }
              $_groups << top_level_group
              yield
            end
          end
        else
          old_before(what, &blk)
        end
      end
    end

Then in spec_helper:

    require 'before_current_group'

    Spec::Runner.configure do |config|
      config.before(:current_group) do
        # re-migrate db for each top-level group (it usually equals one *_spec.rb file)
        DataMapper.auto_migrate!
      end
    end

Voila!

