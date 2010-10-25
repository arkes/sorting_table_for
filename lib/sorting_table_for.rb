# encoding: utf-8

require 'sorting_table_for/table_builder'
require 'sorting_table_for/i18n'
require 'sorting_table_for/tools'

module SortingTableFor
  
  def sorting_table_for(object_or_array, *args, &proc)
    raise ArgumentError, 'Missing block' unless block_given?
    options = args.extract_options!
    html_options = options[:html]
    html_options = (html_options) ? options[:html].merge!(:class => "#{html_options[:class]} sorting_table_for") : { :class => :sorting_table_for }
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
    concat(Tools::html_safe(tag(:table, html_options, true)))
    yield builder.new(object, object_or_array, self, options, params)
    concat(Tools::html_safe('</table>'))
  end
  
end

# Include in ActionView Helper
if defined? ActionView
 ActionView::Base.send(:include, SortingTableFor)
end
