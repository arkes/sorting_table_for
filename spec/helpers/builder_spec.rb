# encoding: utf-8

require 'spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../fixtures/user')

include SortingTableForSpecHelper

describe SortingTableFor, :type => :helper do
  
  before :each do
    @users = User.all
    helper.stub!(:url_for).and_return('fake_link')
    helper.stub!(:params).and_return({ :controller => 'fakes', :action => 'index' })
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
      helper.output_buffer.should have_comp_tag("table[class=sorting_table_for]")
    end
    
    it "should be custom by html" do
      table_html = helper.sorting_table_for(@users, :html => { :class => 'hello', :id => 'my_test' }) {}
      helper.output_buffer.concat(table_html)
      helper.output_buffer.should have_comp_tag("table[class='hello sorting_table_for'][id='my_test']")
    end
    
    it "should take another builder" do
      class MyNewBuilder < SortingTableFor::TableBuilder
      end
      helper.sorting_table_for(@users, :builder => MyNewBuilder) do |builder|
        builder.class.should == MyNewBuilder
      end
    end
    
  end
    
end
