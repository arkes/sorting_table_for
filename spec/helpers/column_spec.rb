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
  
  describe ' #default usage' do
  
    it "should works" do
      helper.sorting_table_for(@users) do |table|
        html = table.columns
        html.should have_comp_tag("tbody", :count => 1)
        html.should have_comp_tag("tr", :count => (@users.size + 1))
        html.should have_comp_tag("td", :count => (@users.size * (User.content_columns.size + 2)) + 1)
      end
    end
    
    it "should add total entries" do
      helper.sorting_table_for(@users) do |table|
        table.columns.should match(@users.size.to_s)
      end
    end
    
    it "should add colspan for total entries" do
      helper.sorting_table_for(@users) do |table|
        table.columns.should match("<td colspan=\"" + (User.content_columns.size + 2).to_s  + "\">")
      end
    end
  
    it "should add i18n to total entries" do
      helper.sorting_table_for(@users) do |table|
        table.columns.should match("Total Entries " + @users.size.to_s)
      end
    end
    
    it "should add colspan for total entries" do
      helper.sorting_table_for(@users) do |table|
        table.columns.should match("<td colspan=\"" + (User.content_columns.size + 2).to_s  + "\">")
      end
    end
    
    it "should add link columns" do
      helper.sorting_table_for(@users) do |table|
        table.columns.should have_comp_tag('a', :count => (@users.size * 2))
      end
    end
    
    it "should add i18n to link columns" do
      helper.sorting_table_for(@users) do |table|
        html = table.columns
        html.should have_comp_tag('a', :text => 'Edit', :count => @users.size)
        html.should have_comp_tag('a', :text => 'Delete', :count => @users.size)
      end
    end
    
    it "should add class odd/even" do
      helper.sorting_table_for(@users) do |table|
        html = table.columns
        html.should have_comp_tag("tr[class=odd]", :count => (@users.size / 2))
        html.should have_comp_tag("tr[class=even]", :count => (@users.size / 2))
      end
    end
  
    it "should customize html" do
      table_html = helper.sorting_table_for(@users, :html => { :class => 'table_class', :id => 'table_id' }) do |table|
        html = table.columns :html => { :class => 'hello_class', :id => 'hello_id', :title => 'hello_title' }
        html.should have_comp_tag("tr:nth-child(2)[class='hello_class odd']")
        html.should have_comp_tag("tr:nth-child(2)[id=hello_id]")
        html.should have_comp_tag("tr:nth-child(2)[title=hello_title]")
      end
      helper.output_buffer.concat(table_html)
      helper.output_buffer.should have_comp_tag("table[class='table_class sorting_table_for'][id=table_id]")
    end
    
  end
  
  describe " #table columns" do
    
    it "should works with one column" do
      helper.sorting_table_for(@users) do |table|
        html = table.columns :username
        html.should have_comp_tag("tbody", :count => 1)
        html.should have_comp_tag("tr", :count => (@users.size + 1))
        html.should have_comp_tag("td", :count => (@users.size + 1))        
      end
    end
    
    it "should have multi columns" do
      helper.sorting_table_for(@users) do |table|
        html = table.columns :username, :price
        html.should have_comp_tag("tbody", :count => 1)
        html.should have_comp_tag("tr", :count => (@users.size + 1))
        html.should have_comp_tag("td", :count => ((@users.size * 2) + 1))
      end
    end
    
    it "should have multi columns and action" do
      helper.sorting_table_for(@users) do |table|
        table.columns(:username, :price, :actions => :edit).should have_comp_tag("td", :count => ((@users.size * 3) + 1))
      end      
    end
  
    it "should have multi columns and multi action" do
      helper.sorting_table_for(@users) do |table|
        table.columns(:username, :price, :actions => [:edit, :delete]).should have_comp_tag("td", :count => ((@users.size * 4) + 1))
      end      
    end
    
    it "should do nothing if the key isn't correct" do
      helper.sorting_table_for(@users) do |table|
        table.columns(:username, :price, :blabla => :edit).should have_comp_tag("td", :count => ((@users.size * 2) + 1))
      end
    end
    
    it "should works symbol and non symbol" do
      helper.sorting_table_for(@users) do |table|
        html = table.columns(:username, 'hello', image_tag('rails.png'), :actions => :edit)
        html.should have_comp_tag("tr:nth-child(2) td:nth-child(1)", :text => @users.first.username)
        html.should have_comp_tag("tr:nth-child(2) td:nth-child(2)", :text => 'hello')
        html.should have_comp_tag("tr:nth-child(2) td:nth-child(3) img")
        html.should have_comp_tag("tr:nth-child(2) td:nth-child(4) a")
      end
    end
    
    it "should works with non key symbol" do
      helper.sorting_table_for(@users) do |table|
        html = table.columns(:username, :test)
        html.should have_comp_tag("tr:nth-child(2) td:nth-child(1)", :text => @users.first.username)
        html.should have_comp_tag("tr:nth-child(2) td:nth-child(2)", :text => '')
      end
    end    
    
    it "should add remote on link" do
      helper.sorting_table_for(@users, :link_remote => true) do |table|
        html = table.columns :username, :actions => :edit
        if SortingTableFor::Tools::rails3?
          html.should have_comp_tag("tr:nth-child(2) td:nth-child(2) a[data-remote]")
        else
          html.should have_comp_tag("tr:nth-child(2) td:nth-child(2) a[onclick]")
        end
      end            
    end
    
    it "should customize html" do
      table_html = helper.sorting_table_for(@users, :html => { :class => 'table_class', :id => 'table_id' }) do |table|
        html = table.columns :username, :price, :html => { :class => 'hello_class', :id => 'hello_id', :title => 'hello_title' }
        html.should have_comp_tag("tr:nth-child(2)[class='hello_class odd'][id=hello_id][title=hello_title]")
      end
      helper.output_buffer.concat(table_html)
      helper.output_buffer.should have_comp_tag("table[class='table_class sorting_table_for'][id=table_id]")
    end
  
  end
  
  describe " #table column" do
    
    it "should works with one column" do
      helper.sorting_table_for(@users) do |table|
        html = table.columns do
          table.column :username
        end
        html.should have_comp_tag("tbody", :count => 1)
        html.should have_comp_tag("tr", :count => (@users.size + 1))
        html.should have_comp_tag("td", :count => (@users.size + 1))
      end
    end
  
    it "should have multi columns" do
      helper.sorting_table_for(@users) do |table|
        html = table.columns do
          table.column :username
          table.column :price
        end
        html.should have_comp_tag("tbody", :count => 1)
        html.should have_comp_tag("tr", :count => (@users.size + 1))
        html.should have_comp_tag("td", :count => ((@users.size * 2) + 1))
      end
    end
    
    it "should works with multi types" do
      helper.sorting_table_for(@users) do |table|
        html = table.columns do
          table.column :username
          table.column :test
          table.column 'hello'
          table.column image_tag('rails.png')
          table.column :action => :edit
        end
        html.should have_comp_tag("tr:nth-child(2) td:nth-child(1)", :text => @users.first.username)
        html.should have_comp_tag("tr:nth-child(2) td:nth-child(2)", :text => '')
        html.should have_comp_tag("tr:nth-child(2) td:nth-child(3)", :text => 'hello')
        html.should have_comp_tag("tr:nth-child(2) td:nth-child(4) img")
        html.should have_comp_tag("tr:nth-child(2) td:nth-child(5) a")
      end
    end
    
    it "should customize html" do
      table_html = helper.sorting_table_for(@users, :html => { :class => 'table_class', :id => 'table_id' }) do |table|
        html = table.columns :html => { :class => 'hello_class', :id => 'hello_id', :title => 'hello_title' } do
          table.column :username, :html => { :class => 'hi_class', :id => 'hi_id', :title => 'hi_title' }
        end
        html.should have_comp_tag("tr:nth-child(2)[class='hello_class odd'][id=hello_id][title=hello_title]")
        html.should have_comp_tag("tr:nth-child(2) td:nth-child(1)[class='hi_class'][id=hi_id][title=hi_title]")
      end
      helper.output_buffer.concat(table_html)
      helper.output_buffer.should have_comp_tag("table[class='table_class sorting_table_for'][id=table_id]")
    end
    
  end
  
  describe " #table column with value" do
    
    it "should have the row collection" do
      helper.sorting_table_for(@users) do |table|
        html = table.columns do |value|
          table.column value.username
        end
        html.should have_comp_tag("tbody", :count => 1)
        html.should have_comp_tag("tr", :count => (@users.size + 1))
        html.should have_comp_tag("td", :count => (@users.size + 1))
        html.should have_comp_tag("tr:nth-child(2) td:nth-child(1)", :text => @users.first.username)
      end
    end
    
    it "should have symbol and value" do
      helper.sorting_table_for(@users) do |table|
        html = table.columns do |value|
          table.column :price
          table.column (value.price - 1)
        end
        html.should have_comp_tag("tr:nth-child(2) td:nth-child(1)", :text => number_to_currency(@users.first.price))
        html.should have_comp_tag("tr:nth-child(2) td:nth-child(2)", :text => (@users.first.price - 1).to_s)
      end
    end
    
  end
  
  describe " #table sub column" do
  
    it "should not change symbol" do
      helper.sorting_table_for(@users) do |table|
        html = table.columns do
          table.column do
            :username
          end
          table.column do
            'hello'
          end
        end
        if SortingTableFor::Tools::rails3?
          html.should have_comp_tag('tr:nth-child(2) td:nth-child(1)', :text => '')
        else
          html.should have_comp_tag('tr:nth-child(2) td:nth-child(1)', :text => 'username')
        end
        html.should have_comp_tag('tr:nth-child(2) td:nth-child(2)', :text => 'hello')
      end
    end
  
    it "should works with value" do
      helper.sorting_table_for(@users) do |table|
        html = table.columns do |value|
          table.column do
            value.username
          end
        end
        html.should have_comp_tag('tr:nth-child(2) td:nth-child(1)', :text => @users.first.username)
      end
    end
  
    it "should customize html" do
      table_html = helper.sorting_table_for(@users, :html => { :class => 'table_class', :id => 'table_id' }) do |table|
        html = table.columns :html => { :class => 'hello_class', :id => 'hello_id', :title => 'hello_title' } do
          table.column :html => { :class => 'hi_class', :id => 'hi_id', :title => 'hi_title' } do
            'hello'
          end
        end
        html.should have_comp_tag("tr:nth-child(2)[class='hello_class odd'][id=hello_id][title=hello_title]")
        html.should have_comp_tag("tr:nth-child(2) td:nth-child(1)[class='hi_class'][id=hi_id][title=hi_title]")
      end
      helper.output_buffer.concat(table_html)
      helper.output_buffer.should have_comp_tag("table[class='table_class sorting_table_for'][id=table_id]")
    end
    
  end
  
  describe ' #With editable options' do
    
    before :each do
      ## Restaure default values
      SortingTableFor::TableBuilder.show_total_entries = true
      SortingTableFor::TableBuilder.reserved_columns = [:id, :password, :salt]
      SortingTableFor::TableBuilder.default_actions = [:edit, :delete]
    end
    
    it "should not add total entries" do
      SortingTableFor::TableBuilder.show_total_entries = false
      helper.sorting_table_for(@users) do |table|
        html = table.columns
        html.should_not match("Total Entries " + @users.size.to_s)
        html.should_not match("<td colspan=\"" + (User.content_columns.size + 2).to_s  + "\">")        
      end
    end
    
    it "should add total entries" do
      SortingTableFor::TableBuilder.show_total_entries = true
      helper.sorting_table_for(@users) do |table|
        html = table.columns
        html.should match("Total Entries " + @users.size.to_s)
        html.should match("<td colspan=\"" + (User.content_columns.size + 2).to_s  + "\">")        
      end
    end    
    
    it "should change reserved columns" do
      SortingTableFor::TableBuilder.reserved_columns = [:id, :firstname, :lastname, :position, :salary, :price, :active, :created_at, :updated_at]
      helper.sorting_table_for(@users) do |table|
        html = table.columns
        html.should have_comp_tag("tr", :count => (@users.size + 1))
        html.should have_comp_tag("td", :count => ((@users.size * 3) + 1))
      end
    end
    
    it "Reserved columns should not impact on column" do
      SortingTableFor::TableBuilder.reserved_columns = [:id, :firstname, :lastname, :position, :salary, :price, :active, :created_at, :updated_at]
      helper.sorting_table_for(@users) do |table|
        html = table.columns do
          table.column :username
          table.column :price
        end
        html.should have_comp_tag("td", :count => ((@users.size * 2) + 1))
      end
    end
    
    it "should edit default actions" do
      SortingTableFor::TableBuilder.default_actions = [:show, :edit_password, :edit, :delete]
      helper.sorting_table_for(@users) do |table|
        table.columns.should have_comp_tag("td", :count => (@users.size * (User.content_columns.size + 4)) + 1)
      end
    end
    
    it "should edit default actions" do
      pending('should check if the links are valids')
      SortingTableFor::TableBuilder.default_actions = [:show, :edit_password, :edit, :delete]
      helper.sorting_table_for(@users) do |table|
      end
    end    
    
  end
  ## Add spec for links
end
