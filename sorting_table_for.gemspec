$:.push File.expand_path("../lib", __FILE__)

require "sorting_table_for/version"

Gem::Specification.new do |s|
  s.name        = "sorting_table_for"
  s.version     = SortingTableFor::VERSION
  s.author      = ["Thomas Floch"]
  s.email       = ["thomas.floch@gmail.com"]
  s.homepage    = "http://github.com/arkes/sorting_table_for"
  s.summary     = "A Rails table builder made to easily create and sort a table"
  s.description = "A Rails table builder made to easily create table or sort a table. The syntax is simple to write and easy to read."
  
  s.files = Dir["{lib,spec,assets}/**/*", "init.rb", "CHANGELOG.mdown", "MIT-LICENSE","Rakefile", "README.mdown"]
                
  s.require_path = "lib"

  s.add_dependency "rails", ">= 3.0.0"

  s.add_development_dependency "rails", "~> 3.2"
  s.add_development_dependency 'rspec-rails', '~> 2.11.4'
  s.add_development_dependency 'sqlite3-ruby', '~> 1.3.3'
  s.add_development_dependency 'webrat', '~> 0.7.3'

  s.rubyforge_project = s.name
  s.required_rubygems_version = ">= 1.3.4"
end