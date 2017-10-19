ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'capybara/rails'
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'valid_attribute'

ActiveRecord::Migration.maintain_test_schema!

def resize_window(width, height)
  case Capybara.current_driver
    when :selenium
      # Capybara.current_session.driver.browser.manage.window.resize_to(width, height)
      # page.driver.browser.manage.window.resize_to(width, height)
    when :webkit
      handle = Capybara.current_session.driver.current_window_handle
      Capybara.current_session.driver.resize_window_to(handle, width, height)
    else
      raise NotImplementedError, "resize_window is not supported for #{Capybara.current_driver} driver"
  end
end

drive = "phantom"
if drive == "chromedriver"
  Capybara.register_driver :chrome do |app|
    Capybara::Selenium::Driver.new(app, :browser => :chrome)
  end

  Capybara.default_driver = :chrome
  Capybara.javascript_driver = :chrome
elsif drive == "phantom"
  Capybara.register_driver :poltergeist do |app|
    options = {
        :screen_size => [1440, 900]
    }
    Capybara::Poltergeist::Driver.new(app, options)
  end

  Capybara.default_driver = :poltergeist
  Capybara.javascript_driver = :poltergeist
end


Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.infer_spec_type_from_file_location!
end
