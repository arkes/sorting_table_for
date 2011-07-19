# encoding: utf-8

module SortingTableFor
  
  private
  
  class TableBuilder
    
    include ::ActionView::Helpers
    
    class_inheritable_accessor :reserved_columns, :currency_columns,
                               :default_boolean, :show_total_entries,
                               :params_sort_table, :i18n_default_format_date,
                               :html_sorting_class, :default_actions,
                               :i18n_default_scope, :i18n_add_header_action_scope,
                               :i18n_add_footer_action_scope
    
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
    self.i18n_add_footer_action_scope = :footer
    
    def initialize(collection, object_or_array, template, options, params)
      @collection, @@object_or_array, @@template, @@options, @@params = collection, object_or_array, template, options, params
      set_default_global_options
      I18n.set_options(params, model_name(@collection.first), @@options[:i18n])
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
    # * :sort - true of false to add or not sorting
    # * :html - Hash options: class, id, ...
    # * :caption - set caption on td
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
        capture(&block)
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
    # * :caption - set caption on td
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
        block = capture(&block)
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
    # * :caption - set caption on td    
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
    # * :caption - set caption on td
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
        block = capture(&block)
        @lines.last.add_cell(@current_object, args, nil, block)
      else
        @lines.last.add_cell(@current_object, args)
      end
      nil
    end
    
    # Create a footer around tfoot and tr.
    # It can be called with or without a block.
    # These two exemples are equivalent:
    #
    #  # With a list:
    #  <% sorting_table_for @users do |table| %>
    #    <%= table.footers :username, :firstname %>
    #  <% end %>
    #  
    #  # With a block:
    #  <% sorting_table_for @users do |table| %>
    #    <%= table.footers do %>
    #      <%= table.footer :username %>
    #      <%= table.footer :firstname %>
    #    <% end %>
    #  <% end %>
    #    
    #  # Output:
    #  <table class='sorting_table_for'>
    #    <tfoot>
    #      <tr>
    #        <td>...</td>
    #        <td>...</td>
    #      </tr>
    #    </tfoot>
    #  </table>
    #
    # === Options
    #
    # * :html - Hash options: class, id, ...
    # * :caption - set caption on td
    #
    #  # Exemples:
    #  <% sorting_table_for @users do |table| %>
    #    <%= table.columns :username, :cation => 5 %>
    #  <% end %>
    #
    # === I18n
    #
    # Add a value on scope for footer. Only with symbol.
    #
    #  # Exemple of i18n_add_header_action_scope:
    #  SortingTableFor::TableBuilder.i18n_add_footer_action_scope = :footer
    #
    #  # Ouput:
    #  I18n.t(:edit, :scope => [:current_controller, :current_action]) => en.current_controller.current_action.footer.edit
    #
    def footers(*args, &block)
      column_options, html_options = get_column_and_html_options( args.extract_options! )
      if block_given?
        @footer_line = FormatLine.new(args, column_options, html_options, nil, :tfoot)
        capture(&block)
      else
        @footer_line = FormatLine.new(args, column_options, html_options, @collection.first, :tfoot) if !args.empty?
      end
      render_tfoot
    end
    
    # Create a cell of footer, to have more control.
    # It can be called with or without a block.
    # The three exemples are equivalent:
    #  
    #  # With a block:
    #  <% sorting_table_for @users do |table| %>
    #    <%= table.footers do %>
    #      <%= table.footer :username %>
    #      <%= table.footer :firstname %>
    #    <% end %>
    #  <% end %>
    #
    #  # With a block:
    #  <% sorting_table_for @users do |table| %>
    #    <%= table.footers do %>
    #      <%= table.footer do %>
    #        <%= :username %>
    #      <% end %>
    #      <%= table.footer do %>
    #        <%= :firstname %>
    #      <% end %>
    #    <% end %>
    #  <% end %>    
    #
    # === Options
    #
    # * :html - Hash options: class, id, ...
    # * :caption - set caption on td
    #
    #  # Exemples:
    #  <% sorting_table_for @users do |table| %>
    #    <%= table.columns :username, :cation => 5 %>
    #  <% end %>
    #
    # === I18n
    #
    # Add a value on scope for footer. Only with symbol.
    #
    #  # Exemple of i18n_add_header_action_scope:
    #  SortingTableFor::TableBuilder.i18n_add_footer_action_scope = :footer
    #
    #  # Ouput:
    #  I18n.t(:edit, :scope => [:current_controller, :current_action]) => en.current_controller.current_action.footer.edit
    #
    # With block the value won't be interpreted.
    #
    def footer(*args, &block)
      if block_given?
        block = capture(&block)
        @footer_line.add_cell(@collection.first, args, nil, block)
      else
        @footer_line.add_cell(@collection.first, args)
      end
      nil
    end
    
    # Create a tag caption to set a title to the table
    # It can be called with or without a block.
    # The two exemples are equivalent:
    #
    #  # Without block
    #  <% sorting_table_for @users do |table| %>
    #    <%= table.caption 'hello' %>
    #  <% end %>
    #
    #  # With block
    #  <% sorting_table_for @users do |table| %>
    #    <%= table.caption do %>
    #      'hello'
    #    <% end %>
    #  <% end %>
    #
    #  # Output:
    #  <table class='sorting_table_for'>    
    #    <caption>hello</caption>
    #  </table>
    #
    # === Quick
    #
    # When called without a block or a value, caption is set with I18n translation.
    #
    #  # Exemple of i18n_default_scope:
    #  SortingTableFor::TableBuilder.i18n_default_scope = [:controller, :action]
    #
    #  # Ouput:
    #  I18n.t(:table_caption, :scope => [:current_controller, :current_action]) => en.current_controller.current_action.table_caption
    #
    # === Options
    #
    # * :position - To set the position of the caption: :top, :bottom, :left, :right (default: :top)
    # * :html - Hash options: class, id, ...
    #
    # === Values
    #
    # All the values won't be interpreted.
    #
    def caption(*args, &block)
      @caption[:option], @caption[:html] = get_column_and_html_options( args.extract_options! )
      if block_given?
        @caption[:value] = capture(&block)
      else
        @caption[:value] = (args.empty?) ? I18n.t(:table_caption) : args.first;
      end
      render_caption
    end
    
    protected
    
    # Return the name of the model
    def model_name(object)
      object.present? ? object.class.name : object.to_s.classify
    end
    
    # Send method to ActionView
    def method_missing(name, *args, &block)
      @@template.send(name, *args, &block)
    end
    
    private
    
    def render_caption
      if @caption
        if @caption.has_key? :option and @caption[:option].has_key? :position
          @caption[:html].merge!(:align => @caption[:option][:position])
        end
        return Tools::html_safe(content_tag(:caption, @caption[:value], @caption[:html]))
      end
      ''
    end
    
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
        return Tools::html_safe(content_tag(:tr, content_tag(:td, I18n.t(:total_entries, :scope => :sorting_table_for, :value => total_entries), {:colspan => max_cells}), { :class => 'total-entries' }))
      end
      ''
    end
    
    # Return the balise tfoot and its content
    def render_tfoot
      if @footer_line
        return Tools::html_safe(content_tag(:tfoot, @footer_line.render_line))
      end
      ''
    end
    
    # Set default global options
    # init caption to a new hash
    # Set sort to true if the value isn't defined in options
    # Set i18n to true if the value isn't defined in options
    def set_default_global_options
      @caption = {}
      @@options[:sort] = true if !defined?(@@options[:sort]) or !@@options.has_key? :sort
      @@options[:i18n] = true if !defined?(@@options[:i18n]) or !@@options.has_key? :i18n
    end
    
    # Calculate the total entries
    # Return a tr and td with a colspan of total entries
    def render_total_entries
      if self.show_total_entries
        total_entries = @collection.total_entries rescue @collection.size
        header_total_cells = @header_line ? @header_line.total_cells : 0
        max_cells = (@lines.first.total_cells > header_total_cells) ? @lines.first.total_cells : header_total_cells
        return Tools::html_safe(content_tag(:tr, content_tag(:td, I18n.t(:total_entries, :value => total_entries), {:colspan => max_cells}), { :class => 'total-entries' }))
      end
      ''
    end
    
    # Return options and html options
    def get_column_and_html_options(options)
      return options, options.delete(:html) || {}
    end
    
  end
end