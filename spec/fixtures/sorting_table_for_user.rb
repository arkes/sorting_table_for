class SortingTableForUser < ActiveRecord::Base
  if ::SortingTableFor::Tools::rails3?
    scope :good_position, :conditions => 'position > 3'
    scope :set_limit, lambda { |limit| { :limit => limit } }
  else
    named_scope :good_position, :conditions => 'position > 3'
    named_scope :set_limit, lambda { |limit| { :limit => limit } }
  end
  
end

20.times do |n|
  SortingTableForUser.create( 
      :username => "my_usename_#{n}",
      :firstname => "my_firstname_#{n}",
      :lastname => "my_lastname_#{n}",
      :position => n + 2,
      :salary => n * 424,
      :price => n * 3,
      :active => ((n % 2) == 0) ? true : false,
      :created_at => DateTime.now - 5.days,
      :updated_at => DateTime.now - 2.hours
  )
end
