# encoding: utf-8

require 'spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../fixtures/sorting_table_for_user')

include SortingTableForSpecHelper

describe SortingTableFor, :type => :helper do
  
  before :all do
    routes_rails
  end
  
  before :each do
    @users = SortingTableForUser.all
    helper.stub!(:params).and_return({ :controller => 'sorting_table_for_users', :action => 'index' })
    helper.output_buffer = ''
  end
  
  describe ' #construct table' do
  
    it "should raise and error" do
      expect {
        helper.sorting_table_for(@users)
      }.to raise_error { ArgumentError }
    end
    
    it "should have balise table with class" do
      table_html = helper.sorting_table_for(@users) {}
      helper.output_buffer.concat(table_html)
      helper.output_buffer.should have_selector("table[class=sorting_table_for]")
    end
    
    it "should be custom by html" do
      table_html = helper.sorting_table_for(@users, :html => { :class => 'hello', :id => 'my_test' }) {}
      helper.output_buffer.concat(table_html)
      helper.output_buffer.should have_selector("table[class='hello sorting_table_for'][id='my_test']")
    end
    
    it "should take another builder" do
      class MyNewBuilder < SortingTableFor::TableBuilder
      end
      helper.sorting_table_for(@users, :builder => MyNewBuilder) do |builder|
        builder.class.should == MyNewBuilder
      end
    end
    
    it "should use i18n by default" do
      helper.sorting_table_for(@users) do |table|
        html = table.headers(:username)
        html.should have_selector("th:nth-child(1)", :content => 'Usernames')
      end
    end
    
    it "should not use i18n" do
      helper.sorting_table_for(@users, :i18n => false) do |table|
        html = table.headers(:username)
        html.should have_selector("th:nth-child(1)", :content => 'username')
      end
    end
    
  end
   
  describe " #All" do
    
    it "should works with by default" do
      helper.sorting_table_for(@users) do |table|
        html = table.caption
        html += table.headers
        html += table.columns
        html += table.footers :username
        html.should have_selector("caption", :count => 1)
        html.should have_selector("thead", :count => 1)
        html.should have_selector("tbody", :count => 1)
        html.should have_selector("tfoot", :count => 1)
      end
    end
    
    it "should works with by default" do
      helper.sorting_table_for(@users) do |table|
        html = table.caption 'hello'
        html += table.headers :username
        html += table.columns :username
        html += table.footers :username
        html.should have_selector("thead tr th", :count => 1)
        html.should have_selector("tbody tr td", :count => @users.count + 1)
        html.should have_selector("tbody tr[class=total-entries] td", :count => 1)
        html.should have_selector("tfoot tr td", :count => 1)
      end
    end    
    
  end 
  
end
