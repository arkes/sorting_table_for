# encoding: utf-8

require 'spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../fixtures/sorting_table_for_user')

include SortingTableForSpecHelper

describe SortingTableFor, :type => :helper do

  before :all do
    (SortingTableFor::Tools::rails3?) ? routes_rails3 : routes_rails2
  end

  before :each do
    @users = SortingTableForUser.all
    helper.stub!(:params).and_return({ :controller => 'sorting_table_for_users', :action => 'index' })
    helper.output_buffer = ''
    SortingTableFor::TableBuilder.default_boolean = [I18n.t(:bool_true, :scope => [:sorting_table_for, :columns]), I18n.t(:bool_false, :scope => [:sorting_table_for, :columns])]      
    SortingTableFor::TableBuilder.i18n_default_format_date = :default
  end
  
  it "should format by default values" do
    helper.sorting_table_for(@users) do |table|
      html = table.columns
      html.should have_comp_tag("tr:nth-child(2) td:nth-child(1)", :text => @users.first.username)
      html.should have_comp_tag("tr:nth-child(2) td:nth-child(2)", :text => @users.first.firstname)
      html.should have_comp_tag("tr:nth-child(2) td:nth-child(3)", :text => @users.first.lastname)
      html.should have_comp_tag("tr:nth-child(2) td:nth-child(4)", :text => @users.first.position.to_s)
      html.should have_comp_tag("tr:nth-child(2) td:nth-child(5)", :text => @users.first.salary.to_s)
      html.should have_comp_tag("tr:nth-child(2) td:nth-child(6)", :text => number_to_currency(@users.first.price))
      html.should have_comp_tag("tr:nth-child(2) td:nth-child(7)", :text => "True")
      html.should have_comp_tag("tr:nth-child(2) td:nth-child(8)", :text => I18n.l(@users.first.created_at, :format => :default))
      html.should have_comp_tag("tr:nth-child(2) td:nth-child(9)", :text => I18n.l(@users.first.updated_at, :format => :default))
    end
  end
  
  it "should works with as" do
    current_datetime = DateTime.now
    helper.sorting_table_for(@users) do |table|
      html = table.columns do |value|
        table.column :price
        table.column value.price, :as => :currency
        table.column current_datetime, :as => :time
        table.column current_datetime, :as => :date
        table.column current_datetime, :as => :time, :format => :short
        table.column current_datetime, :as => :date, :format => :short
        table.column true
        table.column :active
      end
      html.should have_comp_tag("tr:nth-child(2) td:nth-child(1)", :text => number_to_currency(@users.first.price))
      html.should have_comp_tag("tr:nth-child(2) td:nth-child(2)", :text => number_to_currency(@users.first.price))
      html.should have_comp_tag("tr:nth-child(2) td:nth-child(3)", :text => I18n.l(current_datetime, :format => :default))
      html.should have_comp_tag("tr:nth-child(2) td:nth-child(4)", :text => I18n.l(current_datetime.to_date, :format => :default)) 
      html.should have_comp_tag("tr:nth-child(2) td:nth-child(5)", :text => I18n.l(current_datetime, :format => :short))
      html.should have_comp_tag("tr:nth-child(2) td:nth-child(6)", :text => I18n.l(current_datetime.to_date, :format => :short))
      html.should have_comp_tag("tr:nth-child(2) td:nth-child(7)", :text => "True")
      html.should have_comp_tag("tr:nth-child(3) td:nth-child(8)", :text => "False")
    end
  end
  
  it "should works with boolean option" do
    SortingTableFor::TableBuilder.default_boolean = ['BoolTrue', 'BoolFalse']
    helper.sorting_table_for(@users) do |table|
      html = table.columns do
        table.column true
        table.column :active
      end
      html.should have_comp_tag("tr:nth-child(2) td:nth-child(1)", :text => "BoolTrue")
      html.should have_comp_tag("tr:nth-child(3) td:nth-child(2)", :text => "BoolFalse")
    end    
  end
  
  it "should works with format date option" do
    SortingTableFor::TableBuilder.i18n_default_format_date = :short
    current_datetime = DateTime.now
    helper.sorting_table_for(@users) do |table|
      html = table.columns do |value|
        table.column :created_at
        table.column current_datetime, :as => :time
        table.column current_datetime, :as => :time, :format => :default
      end
      html.should have_comp_tag("tr:nth-child(2) td:nth-child(1)", :text => I18n.l(@users.first.created_at, :format => :short))
      html.should have_comp_tag("tr:nth-child(2) td:nth-child(2)", :text => I18n.l(current_datetime, :format => :short)) 
      html.should have_comp_tag("tr:nth-child(2) td:nth-child(3)", :text => I18n.l(current_datetime, :format => :default))
    end    
  end
  
end