# encoding: utf-8

require 'spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../fixtures/sorting_table_for_user')

include SortingTableForSpecHelper

describe SortingTableFor do
  describe ' #i18n' do
    
    before :each do
      SortingTableFor::TableBuilder.i18n_default_scope = [ :namespace, :controller, :action ]
      SortingTableFor::I18n.set_options({:controller => 'fakes_controller', :action => 'fake_action'}, 'user')
    end
    
    it "should works by default" do
      SortingTableFor::I18n.set_options({}, 'user')
      SortingTableFor::I18n.t(:test_name).should == 'i18n name'
    end
    
    it "should set default scope" do
      SortingTableFor::I18n.t(:name).should == 'fake name'
    end
    
    it "should not overwrite scope" do
      SortingTableFor::I18n.t(:my_test, :scope => :fake_scope).should == 'Hello'
    end
    
    it "should works with i18n options" do
      SortingTableFor::I18n.t(:my_test, :value => :hello).should == 'say hello'
    end

    it "should works with options add_scope" do
      SortingTableFor::I18n.t(:name, :add_scope => [:add_scope]).should == 'add to scope'
    end
    
    it "should set namespace scope" do
      SortingTableFor::I18n.set_options({:controller => 'fake_namespace/fakes_controller', :action => 'fake_action'}, 'user')
      SortingTableFor::I18n.t(:name).should == 'fake namespace'
    end
    
    it "should set scope with options" do
      SortingTableFor::TableBuilder.i18n_default_scope = [ :action ]
      SortingTableFor::I18n.t(:name).should == 'fake action'
    end
    
    it "should set scope with all options" do
      SortingTableFor::TableBuilder.i18n_default_scope = [ :model, :namespace, :controller, :action ]
      SortingTableFor::I18n.set_options({:controller => 'fake_namespace/fakes_controller', :action => 'fake_action'}, 'user')
      SortingTableFor::I18n.t(:name).should == 'fake'
    end
    
    it "should not replace keywords" do
      SortingTableFor::TableBuilder.i18n_default_scope = [ :controller, :action, :my_add ]
      SortingTableFor::I18n.t(:name).should == 'fake add'
    end
    
  end
end