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
  
  describe ' #default usage' do
    
    it "should set nothing" do
      helper.sorting_table_for(@users) do |table|
        html = table.footers
        html.should_not have_selector("tfoot")
      end
    end
    
  end
  
  describe " #table footers" do
    
    it "should set a footer with argument" do
      helper.sorting_table_for(@users) do |table|
        html = table.footers 'hello'
        html.should have_selector("tfoot", :count => 1)
        html.should have_selector("tr", :count => 1)
        html.should have_selector("td", :count => 1)        
      end
    end

    it "should set a footer with multiple arguments" do
      helper.sorting_table_for(@users) do |table|
        html = table.footers 'hello', 'hi', 'footer'
        html.should have_selector("tfoot", :count => 1)
        html.should have_selector("tr", :count => 1)
        html.should have_selector("td", :count => 3)
      end
    end

    it "should set i18n" do
      helper.sorting_table_for(@users) do |table|
        html = table.footers :username
        html.should have_selector('td', :content => 'UserFoot')
      end
    end

    it "should set i18n for multiple arguments" do
      helper.sorting_table_for(@users) do |table|
        html = table.footers :username, :price
        html.should have_selector('td:nth-child(1)', :content => 'UserFoot')
        html.should have_selector('td:nth-child(2)', :content => 'PriceFoot')
      end
    end

    it "should works with colspan" do
      helper.sorting_table_for(@users) do |table|
        html = table.footers :username, :colspan => 5
        html.should have_selector('td[colspan="5"]')
      end
    end

    it "should be customize with html" do
      table_html = helper.sorting_table_for(@users, :html => { :class => 'table_class', :id => 'table_id' }) do |table|
        html = table.footers :username, :html => { :class => 'header_class', :id => 'header_id' }
        html.should have_selector("tr[class=header_class][id=header_id]")
      end
      helper.output_buffer.concat(table_html)
      helper.output_buffer.should have_selector("table[class='table_class sorting_table_for'][id=table_id]")
    end

  end

  describe " #table footer" do
    
    it "should set a footer with argument" do
      helper.sorting_table_for(@users) do |table|
        html = table.footers do 
          table.footer 'hello'
        end
        html.should have_selector("tfoot", :count => 1)
        html.should have_selector("tr", :count => 1)
        html.should have_selector("td", :count => 1)        
      end
    end

    it "should set a footer with multiple arguments" do
      helper.sorting_table_for(@users) do |table|
        html = table.footers do
          table.footer 'hello'
          table.footer 'hi'
          table.footer 'footer'
        end
        html.should have_selector("tfoot", :count => 1)
        html.should have_selector("tr", :count => 1)
        html.should have_selector("td", :count => 3)
      end
    end

    it "should set i18n" do
      helper.sorting_table_for(@users) do |table|
        html = table.footers do
          table.footer :username
        end
        html.should have_selector('td', :content => 'UserFoot')
      end
    end

    it "should set i18n for multiple arguments" do
      helper.sorting_table_for(@users) do |table|
        html = table.footers do
          table.footer :username
          table.footer :price
        end
        html.should have_selector('td:nth-child(1)', :content => 'UserFoot')
        html.should have_selector('td:nth-child(2)', :content => 'PriceFoot')
      end
    end

    it "should works with colspan" do
      helper.sorting_table_for(@users) do |table|
        html = table.footers do 
          table.footer :username, :colspan => 5
        end
        html.should have_selector('td[colspan="5"]')
      end
    end

    it "should be customize with html" do
      table_html = helper.sorting_table_for(@users, :html => { :class => 'table_class', :id => 'table_id' }) do |table|
        html = table.footers(:html => { :class => 'header_class', :id => 'header_id' }) do
          table.footer :username, :html => { :class => 'cell_1_class', :id => 'cell_1_id', :title => 'hello_1' }
          table.footer :firstname, :html => { :class => 'cell_2_class', :id => 'cell_2_id', :title => 'hello_2' }
          table.footer 'hello', :html => { :class => 'cell_3_class', :id => 'cell_3_id', :title => 'hello_3' }
        end
        html.should have_selector("tr[class=header_class][id=header_id]")
        html.should have_selector("td:nth-child(1)[class='cell_1_class'][id=cell_1_id][title=hello_1]")
        html.should have_selector("td:nth-child(2)[class='cell_2_class'][id=cell_2_id][title=hello_2]")
        html.should have_selector("td:nth-child(3)[class=cell_3_class][id=cell_3_id][title=hello_3]")
      end
      helper.output_buffer.concat(table_html)
      helper.output_buffer.should have_selector("table[class='table_class sorting_table_for'][id=table_id]")
    end

  end
  
  describe " #table footer with block" do
    
    it "should set a footer with argument" do
      helper.sorting_table_for(@users) do |table|
        html = table.footers do 
          table.footer do
            'hello'
          end
        end
        html.should have_selector("tfoot", :count => 1)
        html.should have_selector("tr", :count => 1)
        html.should have_selector("td", :count => 1)        
      end
    end

    it "should set a footer with multiple arguments" do
      helper.sorting_table_for(@users) do |table|
        html = table.footers do
          table.footer do 
            'hello'
          end
          table.footer do
            'hi'
          end
          table.footer do
            'footer'
          end
        end
        html.should have_selector("tfoot", :count => 1)
        html.should have_selector("tr", :count => 1)
        html.should have_selector("td", :count => 3)
      end
    end

    it "should not set i18n" do
      helper.sorting_table_for(@users) do |table|
        html = table.footers do
          table.footer do 
            :username
          end
        end
        html.should_not have_selector('td', :content => 'UserFoot')
      end
    end

    it "should not set i18n for multiple arguments" do
      helper.sorting_table_for(@users) do |table|
        html = table.footers do
          table.footer do
            :username
          end
          table.footer do 
            :price
          end
        end
        html.should_not have_selector('td:nth-child(1)', :content => 'UserFoot')
        html.should_not have_selector('td:nth-child(2)', :content => 'PriceFoot')
      end
    end

    it "should works with colspan" do
      helper.sorting_table_for(@users) do |table|
        html = table.footers do 
          table.footer :colspan => 5 do
            :username
          end
        end
        html.should have_selector('td[colspan="5"]')
      end
    end

    it "should be customize with html" do
      table_html = helper.sorting_table_for(@users, :html => { :class => 'table_class', :id => 'table_id' }) do |table|
        html = table.footers(:html => { :class => 'header_class', :id => 'header_id' }) do
          table.footer :html => { :class => 'cell_1_class', :id => 'cell_1_id', :title => 'hello_1' } do
            :username
          end
          table.footer :html => { :class => 'cell_2_class', :id => 'cell_2_id', :title => 'hello_2' } do
            :firstname
          end
          table.footer :html => { :class => 'cell_3_class', :id => 'cell_3_id', :title => 'hello_3' } do
            'hello'
          end
        end
        html.should have_selector("tr[class=header_class][id=header_id]")
        html.should have_selector("td:nth-child(1)[class='cell_1_class'][id=cell_1_id][title=hello_1]")
        html.should have_selector("td:nth-child(2)[class='cell_2_class'][id=cell_2_id][title=hello_2]")
        html.should have_selector("td:nth-child(3)[class=cell_3_class][id=cell_3_id][title=hello_3]")
      end
      helper.output_buffer.concat(table_html)
      helper.output_buffer.should have_selector("table[class='table_class sorting_table_for'][id=table_id]")
    end

  end
  
  describe " #With editable options" do
    
    before :each do
      ## Restaure default values
      SortingTableFor::TableBuilder.i18n_add_footer_action_scope = :footer
    end
    
    it "should change the i18n add" do
      SortingTableFor::TableBuilder.i18n_add_footer_action_scope = :header
      helper.sorting_table_for(@users) do |table|
        html = table.footers :username, :price
        html.should have_selector('td:nth-child(1)', :content => 'Usernames')
        html.should have_selector('td:nth-child(2)', :content => 'Prices')
      end
    end
    
  end
  
end