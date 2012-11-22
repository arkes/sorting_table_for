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
  
  describe ' #Caption' do
    
    describe ' #Without block' do
      
      it "should set caption tag" do
        helper.sorting_table_for(@users) do |table|
          html = table.caption
          html.should have_comp_tag("caption", :count => 1)
        end
      end
    
      it "should set caption tag with arguments" do
        helper.sorting_table_for(@users) do |table|
          html = table.caption 'hello'
          html.should have_comp_tag("caption", :text => 'hello')
        end
      end
    
      it "should set caption tag with arguments and option position left" do
        helper.sorting_table_for(@users) do |table|
          html = table.caption 'hello', :position => :left
          html.should have_comp_tag("caption[align=left]")
        end
      end
      
      it "should set caption tag with arguments and option position bottom" do
        helper.sorting_table_for(@users) do |table|
          html = table.caption 'hello', :position => :bottom
          html.should have_comp_tag("caption[align=bottom]")
        end
      end
      
      it "should works with html options" do
        helper.sorting_table_for(@users) do |table|
          html = table.caption 'hello', :html => {:class => 'my_class', :id => 'my_id', :title => 'my_title'}
          html.should have_comp_tag("caption[class=my_class][id=my_id][title=my_title]")
        end
      end
      
      it "should works with html options and position option" do
        helper.sorting_table_for(@users) do |table|
          html = table.caption 'hello', :position => :right, :html => {:class => 'my_class', :id => 'my_id', :title => 'my_title'}
          html.should have_comp_tag("caption[class=my_class][id=my_id][title=my_title][align=right]")
        end
      end
      
    end
    
    describe ' #With block' do
      
      it "should set caption tag" do
        helper.sorting_table_for(@users) do |table|
          html = table.caption {}
          html.should have_comp_tag("caption", :count => 1)
        end
      end
      
      it "should set caption tag with arguments" do
        helper.sorting_table_for(@users) do |table|
          html = table.caption do
            'hello'
          end
          html.should have_comp_tag("caption", :text => 'hello')
        end
      end
    
      it "should set caption tag with arguments and option position left" do
        helper.sorting_table_for(@users) do |table|
          html = table.caption :position => :left do
            'hello'
          end 
          html.should have_comp_tag("caption[align=left]")
        end
      end
 
      it "should set caption tag with arguments and option position bottom" do
        helper.sorting_table_for(@users) do |table|
          html = table.caption :position => :bottom do
            'hello'
          end
          html.should have_comp_tag("caption[align=bottom]")
        end
      end
      
      it "should works with html options" do
        helper.sorting_table_for(@users) do |table|
          html = table.caption :html => {:class => 'my_class', :id => 'my_id', :title => 'my_title'} do
            'hello'
          end
          html.should have_comp_tag("caption[class=my_class][id=my_id][title=my_title]")
        end
      end
      
      it "should works with html options and position option" do
        helper.sorting_table_for(@users) do |table|
          html = table.caption :position => :right, :html => {:class => 'my_class', :id => 'my_id', :title => 'my_title'} do
            'hello'
          end
          html.should have_comp_tag("caption[class=my_class][id=my_id][title=my_title][align=right]")
        end
      end
      
    end
  end
  
  describe " #Quick" do
  
    it "should set caption tag with i18n translation" do
      helper.sorting_table_for(@users) do |table|
        html = table.caption
        html.should have_comp_tag("caption", :count => 1)
        html.should have_comp_tag("caption", :text => 'Quick Caption')
      end
    end
  
    it "should set caption tag with arguments and option position left" do
      helper.sorting_table_for(@users) do |table|
        html = table.caption :position => :left
        html.should have_comp_tag("caption[align=left]")
      end
    end
    
    it "should set caption tag with arguments and option position bottom" do
      helper.sorting_table_for(@users) do |table|
        html = table.caption :position => :bottom
        html.should have_comp_tag("caption[align=bottom]")
      end
    end
    
    it "should works with html options" do
      helper.sorting_table_for(@users) do |table|
        html = table.caption :html => {:class => 'my_class', :id => 'my_id', :title => 'my_title'}
        html.should have_comp_tag("caption[class=my_class][id=my_id][title=my_title]")
      end
    end
    
    it "should works with html options and position option" do
      helper.sorting_table_for(@users) do |table|
        html = table.caption :position => :right, :html => {:class => 'my_class', :id => 'my_id', :title => 'my_title'}
        html.should have_comp_tag("caption[class=my_class][id=my_id][title=my_title][align=right]")
      end
    end
    
  end
  
end