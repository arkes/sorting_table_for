require 'rubygems'

begin
  require File.dirname(__FILE__) + '/../../../../spec/spec_helper'
rescue LoadError
  puts "You need to install rspec in your base app"
  exit
end

puts "Launching spec for Rails #{Rails.version}"

if ::SortingTableFor::Tools::rails3?
  RSpec.configure do |config|
    config.include Webrat::Matchers, :type => :views 
  end
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

if ::SortingTableFor::Tools::rails3?
  I18n.load_path = Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'locales', 'test_rails3.yml')]
else
  I18n.load_path = Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'locales', 'test.yml')]
end
I18n.locale = :test
I18n.default_locale = :test

##
## Init plugin
##

require File.join(File.dirname(__FILE__), '..', 'init.rb')

##
## Spec Helper
##

module SortingTableForSpecHelper
  include ActiveSupport
  include SortingTableFor
  
  def routes_rails2
    ActionController::Routing::Routes.clear!
      ActionController::Routing::Routes.draw do |map|
        map.resources :sorting_table_for_users, :member => { :edit_password => :get }
    end
  end
  
  def routes_rails3
    Rails.application.routes.clear!
    Rails.application.routes.draw do
      resources :sorting_table_for_users do
        member do
          get :edit_password
        end
      end
    end
  end
  
  def have_comp_tag(selector, options = {})
    if ::SortingTableFor::Tools::rails3?
      if options.has_key? :text
        options[:content] = options[:text]
        options.delete :text
      end
      return have_selector(selector, options)
    end
    have_tag(selector, options)
  end
  
end