Gem::Specification.new do |s|
  s.name = "sorting_table_for"
  s.version = "0.1.0"
  s.author = "Thomas Floch"
  s.email = "thomas.floch@gmail.com"
  s.homepage = "http://github.com/arkownz/sorting_table_for"
  s.summary = "A Rails table builder made to easily create and sort a table"
  s.description = "A Rails table builder made to easily create table or sort a table. The syntax is simple to write and easy to read."
  
  s.files = Dir["{lib,spec}/**/*", "[A-Z]*", "init.rb"]
  s.require_path = "lib"

  s.rubyforge_project = s.name
  s.required_rubygems_version = ">= 1.3.4"
end