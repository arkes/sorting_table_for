# encoding: utf-8

## All the values here are the defauls

## This is the column you don't want to show by default
## Array with columns name
## SortingTableFor::TableBuilder.reserved_columns = [:id, :password, :salt]

## Set the currency default columns
## Array with columns name
## SortingTableFor::TableBuilder.currency_columns = [:price, :total_price, :currency, :money]

## Set default for the boolean values
## Array with two states
## SortingTableFor::TableBuilder.default_boolean = [I18n.t(:bool_true, :scope => [:sorting_table_for, :columns]), I18n.t(:bool_false, :scope => [:sorting_table_for, :columns])]

## Show the total entries in table
## true or false
## SortingTableFor::TableBuilder.show_total_entries = false

## The name of the url params for sorting
## SortingTableFor::TableBuilder.params_sort_table = :table_sort

## The html classes for sorting
## Array with the tree states
## SortingTableFor::TableBuilder.html_sorting_class = ['cur-sort-not', 'cur_sort_asc', 'cur-sort-desc']

## Set default for actions
## Array with actions
## SortingTableFor::TableBuilder.default_actions = [:edit, :delete]

## The default format for I18n localization
## I18n.l
## SortingTableFor::TableBuilder.i18n_default_format_date = :default

## The default scope for localisation
## I18n.t
## Keywords are: namespace, controller, action, model
## SortingTableFor::TableBuilder.i18n_default_scope = [:namespace, :controller, :action]

## This value is add by default on scope for header of actions
## SortingTableFor::TableBuilder.i18n_add_header_action_scope = :header
