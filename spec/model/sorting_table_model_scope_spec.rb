require 'spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../fixtures/sorting_table_for_user')

describe SortingTableModelScope do
  
  describe "# default usage" do
    
    it "should do nothing with no option" do
      SortingTableForUser.sorting_table.all.should == SortingTableForUser.all
    end
    
    it "should do nothing with option nil" do
      SortingTableForUser.sorting_table(nil).all.should == SortingTableForUser.all
    end
    
    it "should do nothing with all options nil" do
      SortingTableForUser.sorting_table(nil, nil, nil).all.should == SortingTableForUser.all
    end
    
    it "should raise an error with 4 arguments" do
       expect {
          SortingTableForUser.sorting_table(nil, nil, nil, nil).all
        }.to raise_error { ArgumentError }
    end
    
    it "should works with other scope" do
      SortingTableForUser.good_position.sorting_table.set_limit(2).all.should == SortingTableForUser.find(:all, :conditions => 'position > 3', :limit => 2)
    end
    
    it "should not erase other order" do
      # Change order with scope in rails 3.0.3
      if !defined? ActionPack or (ActionPack::VERSION::MAJOR <= 3 and ActionPack::VERSION::MINOR == 0 and ActionPack::VERSION::TINY <= 1)
        current_order = 'lastname asc, firstname desc'
      else
        current_order = 'firstname desc, lastname asc'
      end
      SortingTableForUser.sorting_table(nil, :firstname, :desc).find(:all, :order => 'lastname asc').should == SortingTableForUser.find(:all, :order => current_order)
    end
    
  end
  
  describe "# params usage" do
    
    it "should works with correct params" do
      SortingTableForUser.sorting_table({ "table_sort" => { "username" => "asc" } }).all.should == SortingTableForUser.find(:all, :order => 'username asc')
    end
    
    it "should do nothing with wrong column" do
      SortingTableForUser.sorting_table({ "table_sort" => { "test" => "asc" } }).all.should == SortingTableForUser.all
    end
    
    it "should do nothing with wrong direction" do
      SortingTableForUser.sorting_table({ "table_sort" => { "username" => "test" } }).all.should == SortingTableForUser.all
    end
    
    it "should do nothing with wrong arguments" do
      SortingTableForUser.sorting_table({ "table_sort" => { "price" => nil } }).all.should == SortingTableForUser.all
    end
    
    it "should do nothing with wrong arguments (2)" do
      SortingTableForUser.sorting_table({ "table_sort" => nil }).all.should == SortingTableForUser.all
    end

    it "should order by params not option" do
      SortingTableForUser.sorting_table({ "table_sort" => { "username" => "asc" } }, :firstname, :desc).all.should == SortingTableForUser.find(:all, :order => 'username asc')
    end
    
    it "should works with custom param name" do
      SortingTableFor::TableBuilder.params_sort_table = :sort_my_test
      SortingTableForUser.sorting_table({ "sort_my_test" => { "username" => "asc" } }).all.should == SortingTableForUser.find(:all, :order => 'username asc')
    end
    
  end
  
  describe "# options usage" do
    
    it "should works with option" do
      SortingTableForUser.sorting_table(nil, :username, :desc).all.should == SortingTableForUser.find(:all, :order => 'username desc')
    end
    
    it "should set option asc if not given" do
      SortingTableForUser.sorting_table(nil, :username).all.should == SortingTableForUser.find(:all, :order => 'username asc')
    end
    
    it "should do nothing with wrong column" do
      SortingTableForUser.sorting_table(nil, :test).all.should == SortingTableForUser.all
    end
    
    it "should do nothing with wring direction" do
      SortingTableForUser.sorting_table(nil, :username, :test).all.should == SortingTableForUser.all
    end
    
  end
  
end
