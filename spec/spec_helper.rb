require 'rubygems'
require 'simplecov'
SimpleCov.start
require 'bundler'
Bundler.require
require 'pry'

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
# require File.expand_path("../../config/environment", __FILE__)
require 'webmock/rspec'
require 'vcr_setup'
#require 'capybara/poltergeist'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.expand_path("../../spec/support/**/*.rb", __FILE__)].each {|f| require f}

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures

  # enable if you have issues with the api and need to see queries directly
  # Koala::Utils.level = Logger::DEBUG
end

module TestResponseExtensions
  def json_body
    JSON.parse(self.body)
  end

  def unauthorized?
    code.to_i == 401
  end
end

def test_access_token
  @test_access_token ||= File.read("test_access_token").split("|")[1]
end

def test_account_id
  @test_account_id ||= File.read("test_access_token").split("|")[0]
end

def explain_error(&block)
  raise "missing code block" unless block_given?

  begin
    block.call
  rescue Koala::Facebook::APIError => e
    puts "=== Facebook API Error ===================================="
    body = JSON.parse e.response_body
    body['error'].each { |k, v| printf("%-20s %s\n", k+":", v) }
    puts "==========================================================="
    raise e
  end
end

require File.expand_path("../../lib/zuck", __FILE__)
