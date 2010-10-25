require 'spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../fixtures/user')

describe SortingTableModelScope do
  
  describe "# default usage" do
    
    it "should do nothing with no option" do
      User.sorting_table.all.should == User.all
    end
    
    it "should do nothing with option nil" do
      User.sorting_table(nil).all.should == User.all
    end
    
    it "should do nothing with all options nil" do
      User.sorting_table(nil, nil, nil).all.should == User.all
    end
    
    it "should raise an error with 4 arguments" do
       expect {
          User.sorting_table(nil, nil, nil, nil).all
        }.to raise_error { ArgumentError }
    end
    
    it "should works with other scope" do
      User.good_position.sorting_table.set_limit(2).all.should == User.find(:all, :conditions => 'position > 3', :limit => 2)
    end
    
    it "should not erase other order" do
      User.sorting_table(nil, :firstname, :desc).find(:all, :order => 'lastname asc').should == User.find(:all, :order => 'lastname asc, firstname desc')
    end
    
  end
  
  describe "# params usage" do
    
    it "should works with correct params" do
      User.sorting_table({ "table_sort" => { "username" => "asc" } }).all.should == User.find(:all, :order => 'username asc')
    end
    
    it "should do nothing with wrong column" do
      User.sorting_table({ "table_sort" => { "test" => "asc" } }).all.should == User.all
    end
    
    it "should do nothing with wrong direction" do
      User.sorting_table({ "table_sort" => { "username" => "test" } }).all.should == User.all
    end
    
    it "should do nothing with wrong arguments" do
      User.sorting_table({ "table_sort" => { "price" => nil } }).all.should == User.all
    end
    
    it "should do nothing with wrong arguments (2)" do
      User.sorting_table({ "table_sort" => nil }).all.should == User.all
    end

    it "should order by params not option" do
      User.sorting_table({ "table_sort" => { "username" => "asc" } }, :firstname, :desc).all.should == User.find(:all, :order => 'username asc')
    end
    
    it "should works with custom param name" do
      SortingTableFor::TableBuilder.params_sort_table = :sort_my_test
      User.sorting_table({ "sort_my_test" => { "username" => "asc" } }).all.should == User.find(:all, :order => 'username asc')
    end
    
  end
  
  describe "# options usage" do
    
    it "should works with option" do
      User.sorting_table(nil, :username, :desc).all.should == User.find(:all, :order => 'username desc')
    end
    
    it "should set option asc if not given" do
      User.sorting_table(nil, :username).all.should == User.find(:all, :order => 'username asc')
    end
    
    it "should do nothing with wrong column" do
      User.sorting_table(nil, :test).all.should == User.all
    end
    
    it "should do nothing with wring direction" do
      User.sorting_table(nil, :username, :test).all.should == User.all
    end
    
  end
  
end
