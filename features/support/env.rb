$:.unshift File.join(File.dirname(__FILE__), "..", "..", "lib")

path = File.dirname(__FILE__)

require 'coveralls'
Coveralls.wear_merged!

require 'dotenv'
require 'timecop'

require 'vcr'
require 'webmock/cucumber'
require 'cucumber/rspec/doubles'
require 'capybara'
require 'capybara/cucumber'
require path + '/../../dashboards'
require 'ignore_env'

VCR.configure do |c|
  # Automatically filter all secure details that are stored in the environment
  (ENV.keys-$ignore_env).select { |x| x =~ /\A[A-Z_]*\Z/ }.each do |key|
    c.filter_sensitive_data("<#{key}>") { ENV[key] }
  end
  c.default_cassette_options = { :record => :once }
  c.cassette_library_dir     = 'fixtures/vcr_cassettes'
  c.hook_into :webmock
end

VCR.cucumber_tags do |t|
  t.tag '@vcr', use_scenario_name: true
end

Capybara.app = Sinatra::Application

class DashingWorld
  include Capybara::DSL

  def app
    Sinatra::Application
  end
end

World do
  DashingWorld.new
end
