# encoding: utf-8

require 'spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../fixtures/user')

include SortingTableForSpecHelper

describe SortingTableFor, :type => :helper do

  before :all do
    (Tools::rails3?) ? routes_rails3 : routes_rails2
  end
  
  before :each do
    @users = User.all
    helper.stub!(:params).and_return({ :controller => 'users', :action => 'index' })
    helper.output_buffer = ''
  end
  
  describe ' #header table' do
    
    describe ' #default usage' do
    
      it "should works" do
        helper.sorting_table_for(@users) do |table|
          html = table.headers
          html.should have_comp_tag("thead", :count => 1)
          html.should have_comp_tag("tr", :count => 1)
          html.should have_comp_tag("th", :count => 11)
        end
      end

      it "should add sorting class on th" do
        helper.sorting_table_for(@users) do |table|
          table.headers.should have_comp_tag("th[class='cur-sort-not']", :count => 9)
        end
      end
      
      it "should have link for sorting" do
        helper.sorting_table_for(@users) do |table|
          table.headers.should have_comp_tag("a", :count => 9)
        end
      end
      
      it "should not sort" do
        helper.sorting_table_for(@users, :sort => false) do |table|
          table.headers.should_not have_comp_tag("th[class='cur-sort-not']")
          table.headers.should_not have_comp_tag("a")
        end
      end
      
      it "should be customize with html" do
        table_html = helper.sorting_table_for(@users, :html => { :class => 'table_class', :id => 'table_id' }) do |table|
          html = table.headers(:html => { :class => 'header_class', :id => 'header_id' })
          html.should have_comp_tag("tr[class=header_class][id=header_id]")
        end
        helper.output_buffer.concat(table_html)
        helper.output_buffer.should have_comp_tag("table[class='table_class sorting_table_for'][id=table_id]")
      end
      
      it "should have option colspan" do
        table_html = helper.sorting_table_for(@users) do |table|
          html = table.headers :colspan => 5
          html.should have_comp_tag('th[colspan="5"]', :count => User.content_columns.size)          
        end
      end      

    end
       
    describe ' #custom headers' do
       
      it "should choose one column" do
        helper.sorting_table_for(@users) do |table|
          table.headers(:username).should have_comp_tag("th", :count => 1)
        end
      end
    
      it "should choose multi columns" do
        helper.sorting_table_for(@users) do |table|
          table.headers(:username, :price).should have_comp_tag("th", :count => 2)
        end
      end
    
      it "should choose multi columns and one action" do
        helper.sorting_table_for(@users) do |table|
          table.headers(:username, :price, :actions => :edit).should have_comp_tag("th", :count => 3)
        end
      end
      
      it "should choose multi columns and actions" do
        helper.sorting_table_for(@users) do |table|
          table.headers(:username, :price, :actions => [:edit, :edit_password]).should have_comp_tag("th", :count => 4)
        end
      end
      
      it "should works with non symbol field" do
        helper.sorting_table_for(@users) do |table|
          html = table.headers(:username, 'test', image_tag('rails.png'))
          html.should have_comp_tag("th", :count => 3)
          html.should have_comp_tag("th:nth-child(2)", :text => 'test')
          html.should have_comp_tag("th:nth-child(3) img")
        end
      end
      
      it "should works with non key symbol" do
        helper.sorting_table_for(@users) do |table|
          table.headers(:username, :test).should have_comp_tag("th", :count => 2)
        end
      end
      
      it "should works with i18n for symbol" do
        helper.sorting_table_for(@users) do |table|
          html = table.headers(:username, :firstname, 'hello', :my_fake, :actions => :edit)
          html.should have_comp_tag("th:nth-child(1)", :text => 'Usernames')
          html.should have_comp_tag("th:nth-child(2)", :text => 'Firstnames')
          html.should have_comp_tag("th:nth-child(3)", :text => 'hello')
          html.should have_comp_tag("th:nth-child(4)", :text => 'Hello fake')
          html.should have_comp_tag("th:nth-child(5)", :text => 'Edit users')          
        end
      end

      it "should have option colspan" do
        table_html = helper.sorting_table_for(@users) do |table|
          html = table.headers :username, :colspan => 5
          html.should have_comp_tag('th[colspan="5"]', :count => 1)
        end
      end
      
    end
    
    describe " #custom header" do
      
      it "should works" do
        helper.sorting_table_for(@users) do |table|
          html = table.headers do
            table.header(:username)
          end
          html.should have_comp_tag("thead", :count => 1)
          html.should have_comp_tag("tr", :count => 1)
          html.should have_comp_tag("th", :count => 1)
        end
      end
      
      it "should works all value" do
        helper.sorting_table_for(@users) do |table|
          html = table.headers do
            table.header :username
            table.header :price
            table.header 'test'
            table.header image_tag('rails.png')
            table.header I18n.t('my_test', :scope => [:fake_scope])
          end
          html.should have_comp_tag("th", :count => 5)
          html.should have_comp_tag("th[class=cur-sort-not]", :count => 2)
          html.should have_comp_tag("th:nth-child(3)", :text => 'test')
          html.should have_comp_tag("th:nth-child(4) img")
          html.should have_comp_tag('th:nth-child(5)', :text => 'Hello')
        end
      end
      
      it "should be customize with html" do
        table_html = helper.sorting_table_for(@users, :html => { :class => 'table_class', :id => 'table_id' }) do |table|
          html = table.headers(:html => { :class => 'header_class', :id => 'header_id' }) do
            table.header :username, :html => { :class => 'cell_1_class', :id => 'cell_1_id', :title => 'hello_1' }
            table.header :firstname, :html => { :class => 'cell_2_class', :id => 'cell_2_id', :title => 'hello_2' }
            table.header 'hello', :html => { :class => 'cell_3_class', :id => 'cell_3_id', :title => 'hello_3' }
          end
          html.should have_comp_tag("tr[class=header_class][id=header_id]")
          html.should have_comp_tag("th:nth-child(1)[class='cell_1_class cur-sort-not'][id=cell_1_id][title=hello_1]")
          html.should have_comp_tag("th:nth-child(2)[class='cell_2_class cur-sort-not'][id=cell_2_id][title=hello_2]")
          html.should have_comp_tag("th:nth-child(3)[class=cell_3_class][id=cell_3_id][title=hello_3]")
        end
        helper.output_buffer.concat(table_html)
        helper.output_buffer.should have_comp_tag("table[class='table_class sorting_table_for'][id=table_id]")
      end
    
      it "should works with i18n for symbol" do
        helper.sorting_table_for(@users) do |table|
          html = table.headers do 
            table.header :username
            table.header :firstname
            table.header 'hello'
            table.header :my_fake
            table.header :action => :edit
          end
          html.should have_comp_tag("th:nth-child(1)", :text => 'Usernames')
          html.should have_comp_tag("th:nth-child(2)", :text => 'Firstnames')
          html.should have_comp_tag("th:nth-child(3)", :text => 'hello')
          html.should have_comp_tag("th:nth-child(4)", :text => 'Hello fake')
          html.should have_comp_tag("th:nth-child(5)", :text => 'Edit users')          
        end
      end
    
      it "should not sort all columns" do
        helper.sorting_table_for(@users, :sort => false) do |table|
          html = table.headers do
            table.header :username
            table.header :price
          end
          html.should_not have_comp_tag("th[class=cur-sort-not]")
        end
      end
    
      it "should not sort on select columns" do
        helper.sorting_table_for(@users) do |table|
          html = table.headers do
            table.header :username, :sort => true
            table.header :price, :sort => false
          end
          html.should have_comp_tag("th:nth-child(1)[class=cur-sort-not]")
          html.should_not have_comp_tag("th:nth-child(2)[class=cur-sort-not]")
        end        
      end
      
      it "should not sort on select columns with global" do
        helper.sorting_table_for(@users, :sort => false) do |table|
          html = table.headers do
            table.header :username, :sort => true
            table.header :price, :sort => false
          end
          html.should have_comp_tag("th:nth-child(1)[class=cur-sort-not]")
          html.should_not have_comp_tag("th:nth-child(2)[class=cur-sort-not]")
        end
      end
      
      it "should works with options sort_as" do
        helper.sorting_table_for(@users) do |table|
          html = table.headers do
            table.header 'my name', :sort_as => :username
          end
          html.should have_comp_tag("th:nth-child(1)", :text => 'my name')
          html.should have_comp_tag("th:nth-child(1)[class=cur-sort-not]")
        end
      end

      it "should works with options sort_as and sort" do
        helper.sorting_table_for(@users, :sort => false) do |table|
          html = table.headers do
            table.header 'my name', :sort_as => :username, :sort => true
            table.header :price
          end
          html.should have_comp_tag("th:nth-child(1)", :text => 'my name')
          html.should have_comp_tag("th:nth-child(1)[class=cur-sort-not]")
          html.should_not have_comp_tag("th:nth-child(2)[class=cur-sort-not]")
        end
      end

      it "should have option colspan" do
        table_html = helper.sorting_table_for(@users) do |table|
          html = table.headers do
            table.header :username, :colspan => 5
            table.header :price, :colspan => 3
          end
          html.should have_comp_tag('th[colspan="5"]', :count => 1)
          html.should have_comp_tag('th[colspan="3"]', :count => 1)
        end
      end      
      
    end
    
    describe ' #custom sub header' do
      
      it "should works" do
        helper.sorting_table_for(@users) do |table|
          html = table.headers do
            table.header do
              :username
            end
            table.header do
              :firstname
            end
          end
          html.should have_comp_tag("th", :count => 2)
        end
      end
      
      it "should not set link for sorting" do
        helper.sorting_table_for(@users) do |table|
          html = table.headers do
            table.header do
              :username
            end
          end
          html.should_not have_comp_tag("a")
        end
      end
      
      it "should not add html class for sorting" do
        helper.sorting_table_for(@users) do |table|
          html = table.headers do
            table.header do
              :username
            end
          end
          html.should_not have_comp_tag("th[class=cur-sort-not]")
        end
      end
      
      it "should not set I18n ici" do
        helper.sorting_table_for(@users) do |table|
          html = table.headers do
            table.header do
              :username
            end
            table.header do
              'firstname'
            end
            table.header do
              I18n.t(:my_test, :scope => :fake_scope)
            end
          end
          if SortingTableFor::Tools::rails3?
            html.should have_comp_tag("th:nth-child(1)", :text => '')
          else
            html.should have_comp_tag("th:nth-child(1)", :text => 'username')
          end
          html.should have_comp_tag("th:nth-child(2)", :text => 'firstname')
          html.should have_comp_tag("th:nth-child(3)", :text => 'Hello')
        end
      end
      
      it "should be customize with html" do
        table_html = helper.sorting_table_for(@users, :html => { :class => 'table_class', :id => 'table_id' }) do |table|
          html = table.headers(:html => { :class => 'header_class', :id => 'header_id' }) do
            table.header :html => { :class => 'cell_1_class', :id => 'cell_1_id', :title => 'hello_1' } do
              :username
            end
            table.header :html => { :class => 'cell_2_class', :id => 'cell_2_id', :title => 'hello_2' } do
              :firstname
            end
            table.header :html => { :class => 'cell_3_class', :id => 'cell_3_id', :title => 'hello_3' } do
              'hello'
            end
          end
          html.should have_comp_tag("tr[class=header_class][id=header_id]")
          html.should have_comp_tag("th:nth-child(1)[class='cell_1_class'][id=cell_1_id][title=hello_1]")
          html.should have_comp_tag("th:nth-child(2)[class='cell_2_class'][id=cell_2_id][title=hello_2]")
          html.should have_comp_tag("th:nth-child(3)[class=cell_3_class][id=cell_3_id][title=hello_3]")
        end
        helper.output_buffer.concat(table_html)
        helper.output_buffer.should have_comp_tag("table[class='table_class sorting_table_for'][id=table_id]")
      end
      
      it "should have option colspan" do
        table_html = helper.sorting_table_for(@users) do |table|
          html = table.headers do
            table.header :colspan => 5 do
              'my_colspan'
            end
            table.header :colspan => 3 do
              'my_colspan_2'
            end
          end
          html.should have_comp_tag('th[colspan="5"]', :count => 1)
          html.should have_comp_tag('th[colspan="3"]', :count => 1)
        end
      end
      
    end
    
    describe ' #With editable options' do
      
      before :each do
        ## Restaure default values
        SortingTableFor::TableBuilder.reserved_columns = [:id, :password, :salt]
        SortingTableFor::TableBuilder.default_actions = [:edit, :delete]
        SortingTableFor::TableBuilder.params_sort_table = :table_sort
        SortingTableFor::TableBuilder.i18n_add_header_action_scope = :header 
      end
      
      it "should edit reserved columns" do
        SortingTableFor::TableBuilder.reserved_columns = [:id, :firstname, :lastname, :position, :salary, :price, :active, :created_at, :updated_at]
        helper.sorting_table_for(@users) do |table|
          table.headers.should have_comp_tag("th", :count => 3)
        end
      end
      
      it "should edit params sort table" do
        pending("Check if the link is edit")
        SortingTableFor::TableBuilder.params_sort_table = :hello_table
        helper.sorting_table_for(@users) do |table|
        end        
      end
    
      it "should edit default actions" do
        SortingTableFor::TableBuilder.default_actions = [:show, :edit_password, :edit, :delete]
        helper.sorting_table_for(@users) do |table|
          table.headers.should have_comp_tag("th", :count => User.column_names.size + 3)
        end
      end
      
      it "should edit default actions" do
        pending('check if the link is valid')
        SortingTableFor::TableBuilder.default_actions = [:show, :edit_password]
        helper.sorting_table_for(@users) do |table|
        end
      end
      
      it "should change the i18n add" do
        SortingTableFor::TableBuilder.i18n_add_header_action_scope = :footer
        helper.sorting_table_for(@users) do |table|
          html = table.headers :username, :price
          html.should have_comp_tag('th:nth-child(1)', :text => 'UserFoot')
          html.should have_comp_tag('th:nth-child(2)', :text => 'PriceFoot')
        end
      end
      
    end
    
  end
  
end
