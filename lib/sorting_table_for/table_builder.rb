# encoding: utf-8

module SortingTableFor
  
  private
  
  class TableBuilder
    
    include ::ActionView::Helpers::TagHelper
    include ::ActionView::Helpers::NumberHelper
    
    class_inheritable_accessor :reserved_columns, :currency_columns,
                               :default_boolean, :show_total_entries,
                               :params_sort_table, :i18n_default_format_date,
                               :html_sorting_class, :default_actions,
                               :i18n_default_scope, :i18n_add_header_action_scope
    
    self.reserved_columns             = [:id, :password, :salt]
    self.currency_columns             = [:price, :total_price, :currency, :money]
    self.default_boolean              = [::I18n.t(:bolean_true, :scope => [:sorting_table_for, :columns]), ::I18n.t(:bolean_false, :scope => [:sorting_table_for, :columns])]
    self.show_total_entries           = true
    self.params_sort_table            = :table_sort
    self.i18n_default_format_date     = :default
    self.html_sorting_class           = [:'cur-sort-not', :'cur-sort-asc', :'cur-sort-desc']
    self.default_actions              = [:edit, :delete]
    self.i18n_default_scope           = [:namespace, :controller, :action]
    self.i18n_add_header_action_scope = :header
    
    def initialize(collection, object_or_array, template, options, params)
      @collection, @@object_or_array, @@template, @@options, @@params = collection, object_or_array, template, options, params
      I18n.set_options(params, model_name(@collection.first), object_or_array.first)
      set_default_global_options
      @lines = []
    end
    
    ##  Headers
    
    def headers(*args, &block)
      column_options, html_options = get_column_and_html_options( args.extract_options! )
      if block_given?
        @header_line = FormatLine.new(args, column_options, html_options, nil, :thead)
        @@template.capture(&block)
      else
        @header_line = FormatLine.new(args, column_options, html_options, @collection.first, :thead)
      end
      render_thead
    end
    
    def header(*args, &block)
      if block_given?
        block = @@template.capture(&block)
        @header_line.add_cell(@collection.first, args, nil, block)
      else
        @header_line.add_cell(@collection.first, args)
      end
      nil
    end
    
    ##  Columns
    
    def columns(*args, &block)
      column_options, html_options = get_column_and_html_options( args.extract_options! )
      @collection.each do |object|
        @current_object = object
        if block_given?
          @lines << FormatLine.new(args, column_options, html_options)
          yield(object)
        else
          @lines << FormatLine.new(args, column_options, html_options, object)
        end
      end
      render_tbody
    end
    
    def column(*args, &block)
      if block_given?
        block = @@template.capture(&block)
        @lines.last.add_cell(@current_object, args, nil, block)
      else
        @lines.last.add_cell(@current_object, args)
      end
      nil
    end
    
    protected
    
    # This function is a copy from Formtastic: http://github.com/justinfrench/formtastic
    def model_name(object)
      object.present? ? object.class.name : object.to_s.classify
    end
    
    private

    def render_thead
      if @header_line
        return Tools::html_safe(content_tag(:thead, @header_line.render_line))
      end
      ''
    end

    def render_tbody
      if @lines and @lines.size > 0
        return Tools::html_safe(content_tag(:tbody, render_total_entries + Tools::html_safe(@lines.collect { |line| line.render_line }.join)))
      end
      ''
    end
    
    def set_default_global_options
      @@options[:sort] = true unless @@options.has_key? :sort
    end
    
    def render_total_entries
      if self.show_total_entries
        total_entries = @collection.total_entries rescue @collection.size
        return Tools::html_safe(content_tag(:tr, content_tag(:td, I18n.t(:total_entries, :scope => :sorting_table_for, :value => total_entries), {:colspan => @lines.first.total_cells}), { :class => 'total-entries' }))
      end
      ''
    end
    
    def get_column_and_html_options(options)
      return options, options.delete(:html) || {}
    end
    
  end
  
  ##
  ##  Format Lines
  ##
  ##
  ##
  
  class FormatLine < TableBuilder
    
    def initialize(args, column_options = {}, html_options = {}, object = nil, type = nil)
      @args, @column_options, @html_options, @object, @type = args, column_options, html_options, object, type
      @cells = []
      if object
        @attributes = (args.empty?) ? (get_columns - TableBuilder.reserved_columns) : @args
        create_cells
      end
    end
    
    def add_cell(object, args, type =nil, block = nil)
      @cells << FormatCell.new(object, args, type, block)
    end
    
    def render_line
      if @type == :thead
        header = content_tag(:tr, Tools::html_safe(@cells.collect { |cell| cell.render_cell_thead }.join), @html_options)
      else
        content_tag(:tr, Tools::html_safe(@cells.collect { |cell| cell.render_cell_tbody }.join), @html_options.merge(:class => "#{@html_options[:class]} #{@@template.cycle(:odd, :even)}".strip))
      end
    end
    
    def total_cells
      @cells.size.to_s
    end
    
    protected
    
    # This function is a copy from Formtastic: http://github.com/justinfrench/formtastic
    def content_columns
      model_name(@object).constantize.content_columns.collect { |c| c.name.to_sym }.compact rescue []
    end
    
    def model_have_column?(column)
      model_name(@object).constantize.content_columns.each do |model_column|
        return true if model_column.name == column.to_s
      end
      false
    end
    
    def can_sort_column?(column)
      model_have_column?(column)
    end
    
    private
    
    def create_cells
      @attributes.each { |ask| add_cell(@object, ask) }
      if @args.empty?
        TableBuilder.default_actions.each { |action| add_cell(@object, action, :action) }
      else
        get_column_actions.each { |action| add_cell(@object, action, :action) }
      end
    end
    
    def get_column_actions
      if @column_options.has_key? :actions
        if @column_options[:actions].is_a?(Array)
          return @column_options[:actions]
        else
          return [ @column_options[:actions] ]
        end
      end
      []
    end
    
    def get_columns
      if @column_options.has_key? :only
        return @column_options[:only] if @column_options[:only].is_a?(Array)
        [ @column_options[:only] ]
      elsif @column_options.has_key? :except
        return content_columns - @column_options[:except] if @column_options[:except].is_a?(Array)
        content_columns - [ @column_options[:except] ] 
      else
        content_columns
      end
    end

  end

  ##
  ## Format Cells
  ##
  ##
  ##

  class FormatCell < FormatLine
    
    def initialize(object, args, type = nil, block = nil)
      @object, @type, @block = object, type, block
      if args.is_a? Array
        @options, @html_options = get_cell_and_html_options( args.extract_options! )
        @ask = args.first
        if @ask.nil? and @options.has_key?(:action)
          @type = :action 
          @ask = @options[:action]
        end
      else
        @ask = args
      end
      set_default_options
      @can_sort = true if @options and @options[:sort] and can_sort_column?(@ask)
    end
    
    def render_cell_tbody
      if @type == :action
        cell_value = action_link_to(@ask)
      elsif @ask
        cell_value = (@ask.is_a?(Symbol)) ? format_cell_value(@object[@ask], @ask) : format_cell_value(@ask)
      else
        cell_value = @block
      end
      cell_value = action_link_to(@options[:action], cell_value) if @type != :action and @options.has_key?(:action)
      content_tag(:td, cell_value, @html_options)
    end
    
    def render_cell_thead
      if @ask
        cell_value = (@ask.is_a?(Symbol)) ? I18n.t(@ask, {}, true) : @ask
      else
        cell_value = @block
      end
      if @can_sort and @options[:sort]
        @html_options.merge!(:class => "#{@html_options[:class]} #{sorting_html_class}".strip)
        content_tag(:th, sort_link_to(cell_value), @html_options)
      else
        content_tag(:th, cell_value, @html_options)
      end
    end
    
    private
    
    def get_cell_and_html_options(options)
      return options, options.delete(:html) || {}
    end
    
    def set_default_options
      @html_options = {} unless defined? @html_options
      @options = {} unless defined? @options
      @options[:sort] = @@options[:sort] or true if !@options.has_key? :sort
    end
    
    def action_link_to(action, block = nil)
      object_or_array = @@object_or_array.clone
      object_or_array.push @object
      return case action.to_sym
        when :delete
          create_link_to(block || I18n.t(:delete), object_or_array, @@options[:link_remote], :delete, I18n.t(:confirm_delete))
        when :show
          create_link_to(block || I18n.t(:show), object_or_array, @@options[:link_remote])
        else
          object_or_array.insert(0, action)
          create_link_to(block || I18n.t(@ask), object_or_array, @@options[:link_remote])
      end
    end
    
    def sort_link_to(name)
      create_link_to(name, sort_url, @@options[:sort_remote])
    end
    
    def create_link_to(block, url, remote, method = nil, confirm = nil)
      if remote and Tools::rails3?
        return @@template.link_to(block, url, :method => method, :confirm => confirm, :remote => true)
      elsif remote
        method = :get if method.nil?
        return @@template.link_to_remote(block, { :url => url, :method => method, :confirm => confirm })
      end
      @@template.link_to(block, url, :method => method, :confirm => confirm)
    end
    
    def sorting_html_class
      return TableBuilder.html_sorting_class.first if current_sorting.nil?
      return TableBuilder.html_sorting_class.second if current_sorting == :asc
      TableBuilder.html_sorting_class.third
    end
    
    def sort_url
      url_params = @@params.clone
      if url_params.has_key? TableBuilder.params_sort_table
        if url_params[TableBuilder.params_sort_table].has_key? @ask
          url_params[TableBuilder.params_sort_table][@ask] = inverse_sorting
          return @@template.url_for(url_params)
        end
        url_params[TableBuilder.params_sort_table].delete @ask
      end
      url_params[TableBuilder.params_sort_table] = { @ask => :asc }
      @@template.url_for(url_params)
    end
    
    def current_sorting
      if @@params.has_key? TableBuilder.params_sort_table and @@params[TableBuilder.params_sort_table].has_key? @ask
        return @@params[TableBuilder.params_sort_table][@ask].to_sym
      end
      nil
    end
    
    def inverse_sorting
      return :asc if current_sorting.nil?
      return :desc if current_sorting == :asc
      :asc
    end
    
    def format_cell_value(value, attribute = nil)
      unless (ret_value = format_cell_value_as_ask(value)).nil?
        return ret_value
      end
      format_cell_value_as_type(value, attribute)
    end
    
    def format_cell_value_as_ask(value)
      return nil if !@options or @options.empty? or !@options.has_key?(:as)
      return case @options[:as]
        when :date then ::I18n.l(value.to_date, :format => @options[:format] || TableBuilder.i18n_default_format_date)
        when :time then ::I18n.l(value.to_datetime, :format => @options[:format] || TableBuilder.i18n_default_format_date)
        when :currency then number_to_currency(value)
        else nil
      end
    end
    
    def format_cell_value_as_type(value, attribute)
      if value.is_a?(Time) or value.is_a?(Date)
        return ::I18n.l(value, :format => @options[:format] || TableBuilder.i18n_default_format_date)
      elsif TableBuilder.currency_columns.include?(attribute)
        return number_to_currency(value)
      elsif value.is_a?(TrueClass)
        return TableBuilder.default_boolean.first
      elsif value.is_a?(FalseClass)
        return TableBuilder.default_boolean.second
      end
      value
    end
    
  end
end
