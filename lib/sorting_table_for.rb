# encoding: utf-8

require 'sorting_table_for/model_scope'
require 'sorting_table_for/table_builder'
require 'sorting_table_for/format_line'
require 'sorting_table_for/format_cell'
require 'sorting_table_for/i18n'
require 'sorting_table_for/tools'

module SortingTableFor
  
  # Method sorting_table_for with builder => SortingTableFor::TableBuilder
  #
  #  # Exemples :
  #  <% sorting_table_for @users do |table| %>
  #  <% end %>
  #
  #  <% sorting_table_for @users do |table| %>
  #    <%= table.caption %>
  #    <%= table.headers %>
  #    <%= table.columns %>
  #    <%= table.footers %>
  #  <% end %>
  #
  # === Options
  #
  # * :builder - Set a table builder, default: SortingTableFor::TableBuilder
  # * :html - Set html options (id, class, ...), default: empty
  # * :remote_link - To set actions link with ajax (true or false), default: false
  # * :remote_sort - To set link for sorting with ajax (true of false), default: false
  # * :i18n - To use or not i18n on values (true or false), default: true
  #
  def sorting_table_for(object_or_array, *args)
    raise ArgumentError, 'Missing block' unless block_given?
    options = args.extract_options!
    html_options = (options[:html]) ? options[:html].merge(:class => "#{options[:html][:class]} sorting_table_for".strip) : { :class => :sorting_table_for }
    builder = options[:builder] || TableBuilder
    case object_or_array
      when Array
        if object_or_array.last.is_a?(Array)
          object = object_or_array.last
          object_or_array.pop
        else
          object = object_or_array
          object_or_array = []
        end
      else
        object = object_or_array
        object_or_array = []
    end
    content_tag(:table, html_options) do
      yield builder.new(object, object_or_array, self, options, params)
    end
  end
  
end

# Include in ActionView Helper
if defined? ActionView
 ActionView::Base.send(:include, SortingTableFor)
end
