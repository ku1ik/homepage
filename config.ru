require 'yaml'
YAML::ENGINE.yamler= 'syck'

require "bundler/setup"
Bundler.require

require File.expand_path(File.join(File.dirname(__FILE__), "app"))

run Sinatra::Application
