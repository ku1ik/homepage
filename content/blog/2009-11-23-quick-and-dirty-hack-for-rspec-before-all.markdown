title: Quick and dirty hack for RSpec's before(:all)
date: 2009-11-23 19:41
tags: ruby, rspec, testing

RSpec is generally nice testing framework. It supports _before_ and _after_ hooks which can be invoked before/after _each_ test case or _all_ test cases.
_before(:all)_ is a little confusing though. It runs your "before" block before all "describes" and "contexts", also nested ones. Here's example:

    describe User do
      before(:all) { puts "preparing for war" }
      it "should foo" do
        ...
      end
      context "active" do
        it "should bar" do
          ...
        end
      end
      context "inactive" do
        it "should baz" do
          ...
        end
      end
    end

I would expect "preparing for war" to show up once. But _before(:all)_ was called thrice. First, for top level "describe", then two times for "contexts".
There were [some suggestions](https://rspec.lighthouseapp.com/projects/5645/tickets/819-beforeall-executes-multiple-times-with-nested-example-groups) to change this behaviour or to add and option to [skip call for nested groups](https://rspec.lighthouseapp.com/projects/5645/tickets/632) but nothing has changed recently. People are even trying some crazy hacks like [this](http://www.swombat.com/getting-rspec-beforeall-and-nested-contexts-w).

What I needed was to wipe database for every model spec and every request spec because factory generated records made my build unstable (due to uniqueness validations). After trying few things I ended up with using _before(:all)_ with some condition. First, I've added _before_top_level_group_ method to Spec::Runner::Configuration and saved it in spec/before_top_level_group.rb:

    $_groups = []

    class Spec::Runner::Configuration
      def before_top_level_group
        before(:all) do
          top_level_group = self.class.to_s[/^.+ExampleGroup::([^:]+)/, 1]
          unless $_groups.any? { |g| top_level_group == g }
            $_groups << top_level_group
            yield
          end
        end
      end
    end

Then in spec_helper I used it like this:

    require 'before_top_level_group'

    Spec::Runner.configure do |config|
      config.before_top_level_group do
        # re-migrate db for each top-level group (it usually equals one *_spec.rb file)
        DataMapper.auto_migrate!
      end
    end

Voila! I know it's a dirty hack but it works for me and I'll be using it until RSpec is patched or I switch my testing framework to something else ([Bacon](http://github.com/chneukirchen/bacon/) looks nice).

