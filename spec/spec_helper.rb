require 'rubygems'
require 'spec'

begin
  require File.dirname(__FILE__) + '/../../../../spec/spec_helper'
rescue LoadError
  puts "You need to install rspec in your base app"
  exit
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

I18n.load_path = Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'locales', '*.yml')]
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
  
  include SortingTableFor
  
end
