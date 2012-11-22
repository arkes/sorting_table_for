# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

RSpec.configure do |config|
  config.include Webrat::Matchers, :type => :views 
end

##
## Load fixtures
##

ActiveRecord::Base.logger = false
#ActiveRecord::Base.logger = Logger.new(File.join(File.dirname(__FILE__), 'debug.log'))

configuration = YAML.load_file(File.join(File.dirname(__FILE__), 'db', 'database.yml'))
ActiveRecord::Base.establish_connection(configuration[ENV["DB"] || "sqlite3"])

ActiveRecord::Base.silence do
  ActiveRecord::Migration.verbose = false
  load(File.join(File.dirname(__FILE__), "db", "schema.rb"))
end

##
## Load I18n locales
##

I18n.load_path = Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'locales', 'test_rails.yml')]
I18n.locale = :test
I18n.default_locale = :test

##
## Init plugin
##

#require File.join(File.dirname(__FILE__), '..', 'init.rb')

##
## Spec Helper
##

module SortingTableForSpecHelper
  include ActiveSupport
  include SortingTableFor
  
  def routes_rails
    Rails.application.routes.clear!
    Rails.application.routes.draw do
      resources :sorting_table_for_users do
        member do
          get :edit_password
        end
      end
    end
  end
  
end