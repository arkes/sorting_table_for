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
    
    # Create a header with the name of the columns (th) around thead and tr.
    # It can be called with or without a block, or with a list of columns.
    # By default it will add the default actions (edit, delete).
    # Also by default it will add a link to sort to the column.
    # These two exemples are equivalent:
    # 
    #  # With a block:
    #  <% sorting_table_for @users do |table| %>
    #    <%= table.headers do %>
    #      <%= table.header :username %>
    #      <%= table.header :firstname %>
    #    <% end %>
    #  <% end %>
    #
    #  # With a list:
    #  <% sorting_table_for @users do |table| %>
    #    <%= table.headers :username, :firstname %>
    #  <% end %>
    #
    #  # Output:
    #  <table class='sorting_table_for'>
    #    <thead>
    #      <tr>
    #        <th class='cur-sort-not'><a href='/my_link?table_sort[username]=asc'>...</a></th>
    #        <th class='cur-sort-not'><a href='/my_link?table_sort[firstname]=asc'>...</a></th>
    #        <th>Edit</th>
    #        <th>Delete</th>
    #      </tr>
    #    </thead>
    #  </table>
    #
    # === Quick Headers
    #
    # When called without a block or a list, the headers are rendered for each column in 
    # the model's database table and the default actions (edit, delete), and the links to sort.
    #
    #  <% sorting_table_for @users do |table| %>
    #    <%= table.headers %>
    #  <% end %>
    #
    # === Options
    #
    # All options are passed down to the fieldser HTML attribtues (id, class, title, ...) expect
    # for option sort.
    #   
    #  # Html option:
    #  <% sorting_table_for @users do |table| do %>
    #    <%= table.headers :username, :firstname, :html => { :class => 'my_class', :id => 'my_id' }
    #  <% end %>
    #
    #  # Sort option:
    #  <% sorting_table_for @users do |table| do %>
    #    <%= table.headers :sort => false %>
    #  <% end %>
    #
    # === I18n
    #
    # For each column contained in the model's database table, the name is set with the I18n translation.
    # The translation are scoped by option 'i18n_default_scope' defined in your options.
    #
    #  # Exemple of I18n options for header:
    #  SortingTableFor::TableBuilder.i18n_default_scope = [:controller, :action]
    #
    #  # Ouput:
    #  I18n.t(:username, :scope => [:current_controller, :current_action]) => en.current_controller.current_action.username
    #
    # === Actions
    #
    # The option 'default_actions' contained the actions to add by default to the table. The header's actions
    # are not sortable. The name of action is set with I18n translation.
    # It's possible to add a value in the scope for header by option 'i18n_add_header_action_scope'
    #
    #  # Exemple of default_actions:
    #  SortingTableFor::TableBuilder.default_actions = [:edit]
    #  SortingTableFor::TableBuilder.i18n_add_header_action_scope = :header
    #
    #  # Ouput:
    #  I18n.t(:edit, :scope => [:current_controller, :current_action, :header]) => en.current_controller.current_action.header.edit
    #
    # === Sorting
    #
    # The link for sorting is set if the column is contained in the model's database table. the link for sorting
    # is set with the current url, the builder adds a param 'table_sort'.
    # 
    #  # Exemple for column username:
    #  current url: /my_link
    #  param sort: /my_link?table_sort[username]=asc
    #
    # the name of the param is set by option: TableSortingFor::TableBuilder.params_sort_table
    #
    # === Values
    #
    # the values given to headers could be anything. Only the symbols are set with I18n translation.
    # If you give other types (string, image, ...) there won't have sorting and I18n translation.
    #
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
    
    # Create a cell of header, to have more control.
    # It can be called with or without a block.
    # The three exemples are equivalent:
    #
    #  # Without block (I18n and sorting)
    #  <% sorting_table_for @users do |table| %> 
    #    <%= table.headers do %>
    #      <%= table.header :username %>
    #    <% end %>
    #  <% end %>
    #
    #  # With string (no I18n and no sorting)
    #  <% sorting_table_for @users do |table| %>
    #    <%= table.headers do %>
    #      <%= table.header 'hello_my_header' %>
    #    <% end %>
    #  <% end %>
    #
    #  # With a block and image (no I18n and no sorting)
    #  <% sorting_table_for @users do |table| %>
    #    <%= table.headers do %>
    #      <%= table.header do %>
    #        <%= image_tag('rails.png') %>
    #      <% end %>
    #    <% end %>
    #  <% end %>
    #
    # === Options
    #
    # * :sort - true of false to add or not sorting
    # * :html - Hash options: class, id, ...
    #
    # === Values
    #
    # the values given to header can be anything. Only the symbols are set with I18n translation.
    # If you give other types (string, image, ...) there won't have sorting and I18n translation.
    #
    # With block there won't have sorting and translation.
    #
    def header(*args, &block)
      if block_given?
        block = @@template.capture(&block)
        @header_line.add_cell(@collection.first, args, nil, block)
      else
        @header_line.add_cell(@collection.first, args)
      end
      nil
    end
    
    # Create the content of table with the values of collection (td) around tbody and tr.
    # It can be called with or without a block, or with a list of columns.
    # By default it will add the default actions (edit, delete).
    # The method columns return the current object of the collection.
    # These three exemples are equivalent:
    #
    #  # With a list:
    #  <% sorting_table_for @users do |table| %>
    #    <%= table.columns :username, :firstname %>
    #  <% end %>
    #  
    #  # With a block:
    #  <% sorting_table_for @users do |table| %>
    #    <%= table.columns do %>
    #      <%= table.column :username %>
    #      <%= table.column :firstname %>
    #    <% end %>
    #  <% end %>
    #
    #  # With a block and current object:
    #  <% sorting_table_for @users do |table| %>
    #    <%= table.columns do |user| %>
    #      <%= table.column user.username %>
    #      <%= table.column user.firstname %>
    #    <% end %>
    #  <% end %>
    #    
    #  # Output:
    #  <table class='sorting_table_for'>
    #    <tbody>
    #      <tr>
    #        <td>...</td>
    #        <td>...</td>
    #        <td><a href='/users/1/edit'>Edit<a></td>
    #        <td><a href='/users/1'>Delete</a></td>
    #      </tr>
    #      ...
    #    </tbody>
    #  </table>
    #
    # === Quick Columns
    #
    # When called without a block or a list, the columns are rendered for each column in 
    # the model's database table and the default actions (edit, delete).
    #
    #  <% sorting_table_for @users do |table| %>
    #    <%= table.columns %>
    #  <% end %>
    #
    # === Options
    #
    # * :html - Hash options: class, id, ...
    # * :actions - Set actions to render
    # * :only - Columns only to render
    # * :except - Columns to not render
    #
    #  # Exemples:
    #  <% sorting_table_for @users do |table| %>
    #    <%= table.columns :username, :actions => [:edit, :delete] %>
    #  <% end %>
    #
    #  <% sorting_table for @users do |table| %>
    #    <%= table.columns :except => [:created_at, :updated_at] %>
    #  <% end %>
    #
    # === I18n
    #
    # For each action, the name is set with the I18n translation.
    #
    #  # Exemple of i18n_default_scope:
    #  SortingTableFor::TableBuilder.i18n_default_scope = [:controller, :action]
    #
    #  # Ouput:
    #  I18n.t(:edit, :scope => [:current_controller, :current_action]) => en.current_controller.current_action.edit
    # 
    # === Actions
    #
    # The option 'default_actions' contains the actions to add by default to the table. The link to actions
    # is set by the collection sent to the method sorting_table_for.
    # The name of action is set with I18n translation.
    #
    #  # Exemple of default_actions:
    #  SortingTableFor::TableBuilder.default_actions = [:edit]
    #
    #  # Ouput:
    #  link_to( I18n.t(:edit, :scope => [:current_controller, :current_action]), [:edit, user]) => /users/1/edit
    #
    # For action :delete the builder set a confirm message with I18n translation.
    #
    #  # the I18n confirm message:
    #  I18n.t(:confirm_delete, :scope => [:current_controller, :current_action])
    #
    # === Total entries
    #
    # The first tr of the columns are the number of results in the collection. The line appears if
    # option 'show_total_entries' is set to true.
    #
    #  # Exemple of option:
    #  SortingTableFor::TableBuilder.show_total_entries = true
    #
    #  # Exemple:
    #  <% sorting_table_for @users do |table| %>
    #    <%= table.columns :username, :firstname %>
    #  <% end %>
    #
    #  # Ouput:
    #  <table class='sorting_table_for'>
    #    <tbody>
    #      <tr>
    #        <td colspan='2' class='total-entries'>Total Entries: 42</td>
    #      </tr>
    #      <tr>
    #        <td>...</td>
    #        <td>...</td>
    #      </tr>
    #      ...
    #    </tbody>
    #  </table>
    #
    # A colspan is added by default with the number of columns.
    # Total entries are compatible with the plugin 'will_paginate'.
    # The total entries text if defined by I18n translation.
    #
    #  # I18n translation: 
    #  I18n.t(:total_entries, :scope => :sorting_table_for, :value => total_entries)
    #
    # === Values
    #
    # the values given to columns can be anything. Only the symbols are the values of the collection.
    # If you give other types (string, image, ...) there won't be interpreted.
    #    
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

    # Create a cell of column, to have more control.
    # It can be called with or without a block.
    # The three exemples are equivalent:
    #
    #  # Without block
    #  <% sorting_table_for @users do |table| %> 
    #    <%= table.columns do %>
    #      <%= table.column :username %>
    #    <% end %>
    #  <% end %>
    #
    #  # With current object
    #  <% sorting_table_for @users do |table| %>
    #    <%= table.columns do |user| %>
    #      <%= table.column user.username %>
    #    <% end %>
    #  <% end %>
    #
    #  # With a block and current object
    #  <% sorting_table_for @users do |table| %>
    #    <%= table.columns do |user| %>
    #      <%= table.column do %>
    #        <%= user.username %>
    #      <% end %>
    #    <% end %>
    #  <% end %>
    #
    # === Options
    #
    # * :html - Hash options: class, id, ...
    # * :as - Force to render a type (:date, :time, :currency)
    # * :format - Set the I18n localization format for :date or :time (:default, :short, ...)
    # * :action - Set an action
    #
    #  # Exemple:
    #  <% sorting_table_for @users do |table| %>
    #    <%= table.colums do |user| %>
    #      <%= table.column :username, :html => { :class => 'my_class', :id => 'my_id' }
    #      <%= table.column user.username, :action => :show %>
    #      <%= table.column user.created_at, :as => :date, :format => :short %>
    #      <%= table.column :action => :edit %>
    #    <% end %>
    #  <% end %>
    #
    # === Values
    #
    # the values given to column can be anything. Only the symbols are set with I18n translation.
    # If you give other types (string, image, ...) there won't be interpreted.
    #
    # With block the value won't be interpreted.
    #    
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
    
    # Return the name of the model
    def model_name(object)
      object.present? ? object.class.name : object.to_s.classify
    end
    
    private
    
    # Return the balise thead and its content
    def render_thead
      if @header_line
        return Tools::html_safe(content_tag(:thead, @header_line.render_line))
      end
      ''
    end
    
    # Return the balise tbody and its content
    def render_tbody
      if @lines and @lines.size > 0
        return Tools::html_safe(content_tag(:tbody, render_total_entries + Tools::html_safe(@lines.collect { |line| line.render_line }.join)))
      end
      ''
    end
    
    # Set default global options
    # Set sort to true if the value isn't defined in options
    def set_default_global_options
      @@options[:sort] = true unless @@options.has_key? :sort
    end
    
    # Calculate the total entries
    # Return a tr and td with a colspan of total entries
    def render_total_entries
      if self.show_total_entries
        total_entries = @collection.total_entries rescue @collection.size
        return Tools::html_safe(content_tag(:tr, content_tag(:td, I18n.t(:total_entries, :scope => :sorting_table_for, :value => total_entries), {:colspan => @lines.first.total_cells}), { :class => 'total-entries' }))
      end
      ''
    end
    
    # Return options and html options
    def get_column_and_html_options(options)
      return options, options.delete(:html) || {}
    end
    
  end
  
  class FormatLine < TableBuilder
    
    def initialize(args, column_options = {}, html_options = {}, object = nil, type = nil)
      @args, @column_options, @html_options, @object, @type = args, column_options, html_options, object, type
      @cells = []
      if object
        @attributes = (args.empty?) ? (get_columns - TableBuilder.reserved_columns) : @args
        create_cells
      end
    end
    
    # Create a new cell with the class FormatCell
    # Add the object in @cells
    def add_cell(object, args, type = nil, block = nil)
      @cells << FormatCell.new(object, args, type, block)
    end
    
    # Return a tr line based on the type (:thead or :tbody)
    def render_line
      if @type == :thead
        header = content_tag(:tr, Tools::html_safe(@cells.collect { |cell| cell.render_cell_thead }.join), @html_options)
      else
        content_tag(:tr, Tools::html_safe(@cells.collect { |cell| cell.render_cell_tbody }.join), @html_options.merge(:class => "#{@html_options[:class]} #{@@template.cycle(:odd, :even)}".strip))
      end
    end
    
    # Return a string with the total of cells
    def total_cells
      @cells.size.to_s
    end
    
    protected
    
    # Return each column in the model's database table
    def content_columns
      model_name(@object).constantize.content_columns.collect { |c| c.name.to_sym }.compact rescue []
    end
    
    # Return true if the column is in the model's database table
    def model_have_column?(column)
      model_name(@object).constantize.content_columns.each do |model_column|
        return true if model_column.name == column.to_s
      end
      false
    end
    
    # Return true if the column is in the model's database table
    def can_sort_column?(column)
      model_have_column?(column)
    end
    
    private
    
    # Call after headers or columns with no attributes (table.headers)
    # Create all the cells based on each column in the model's database table
    # Create cell's actions based on option default_actions or on actions given (:actions => [:edit])
    def create_cells
      @attributes.each { |ask| add_cell(@object, ask) }
      if @args.empty?
        TableBuilder.default_actions.each { |action| add_cell(@object, action, :action) }
      else
        get_column_actions.each { |action| add_cell(@object, action, :action) }
      end
    end
    
    # Return an Array of all actions given to headers or columns (:actions => [:edit, :delete])
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
    
    # Return an Array of the columns based on options :only or :except
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
    
    # Return a td with the formated value or action for columns
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
    
    # Return a td with the formated value or action for headers
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
    
    # Return options and html options for a cell
    def get_cell_and_html_options(options)
      return options, options.delete(:html) || {}
    end
    
    # Set default options for cell
    # Set an empty hash if no html options
    # Set an empty hash if no options
    # Set sort to true if no options sort
    def set_default_options
      @html_options = {} unless defined? @html_options
      @options = {} unless defined? @options
      @options[:sort] = @@options[:sort] || true if !@options.has_key? :sort
    end
    
    # Create the link for actions
    # Set the I18n translation or the given block for the link's name
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
    
    # Create sorting link
    def sort_link_to(name)
      create_link_to(name, sort_url, @@options[:sort_remote])
    end
    
    # Create the link based on object
    # Set an ajax link if option link_remote is set to true
    # Compatible with rails 2 and 3.
    def create_link_to(block, url, remote, method = nil, confirm = nil)
      if remote and Tools::rails3?
        return @@template.link_to(block, url, :method => method, :confirm => confirm, :remote => true)
      elsif remote
        method = :get if method.nil?
        return @@template.link_to_remote(block, { :url => url, :method => method, :confirm => confirm })
      end
      @@template.link_to(block, url, :method => method, :confirm => confirm)
    end
    
    # Return a string with html class of sorting for headers
    # The html class is based on option: SortingTableFor::TableBuilder.html_sorting_class
    def sorting_html_class
      return TableBuilder.html_sorting_class.first if current_sorting.nil?
      return TableBuilder.html_sorting_class.second if current_sorting == :asc
      TableBuilder.html_sorting_class.third
    end
    
    # Return an url for sorting
    # Add the param sorting_table[name]=direction to the url
    # Add the default direction: :asc
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
    
    # Return a symbol of the current sorting (:asc, :desc, nil)
    def current_sorting
      if @@params.has_key? TableBuilder.params_sort_table and @@params[TableBuilder.params_sort_table].has_key? @ask
        return @@params[TableBuilder.params_sort_table][@ask].to_sym
      end
      nil
    end
    
    # Return a symbol, the inverse of the current sorting
    def inverse_sorting
      return :asc if current_sorting.nil?
      return :desc if current_sorting == :asc
      :asc
    end
    
    # Return the formated cell's value
    def format_cell_value(value, attribute = nil)
      unless (ret_value = format_cell_value_as_ask(value)).nil?
        return ret_value
      end
      format_cell_value_as_type(value, attribute)
    end
    
    # Format the value if option :as is set
    def format_cell_value_as_ask(value)
      return nil if !@options or @options.empty? or !@options.has_key?(:as)
      return case @options[:as]
        when :date then ::I18n.l(value.to_date, :format => @options[:format] || TableBuilder.i18n_default_format_date)
        when :time then ::I18n.l(value.to_datetime, :format => @options[:format] || TableBuilder.i18n_default_format_date)
        when :currency then number_to_currency(value)
        else nil
      end
    end
    
    # Format the value based on value's type
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
