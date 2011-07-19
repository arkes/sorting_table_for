module SortingTableFor
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
      can_sort_column?
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
        cell_value = (@ask.is_a?(Symbol)) ? I18n.t(@ask, {}, :header) : @ask
      else
        cell_value = @block
      end
      if @can_sort
        sort_on = @options[:sort_as] || @ask
        @html_options.merge!(:class => "#{@html_options[:class]} #{sorting_html_class(sort_on)}".strip)
        content_tag(:th, sort_link_to(cell_value, sort_on), @html_options)
      else
        content_tag(:th, cell_value, @html_options)
      end
    end
  
    def render_cell_tfoot
      if @ask
        cell_value = (@ask.is_a?(Symbol)) ? I18n.t(@ask, {}, :footer) : @ask
      else
        cell_value = @block
      end
      cell_value = action_link_to(@options[:action], cell_value) if @type != :action and @options.has_key?(:action)
      content_tag(:td, cell_value, @html_options)
    end
  
    private
  
    # Return options and html options for a cell
    def get_cell_and_html_options(options)
      return options, options.delete(:html) || {}
    end
  
    # set to true if column is sortable
    def can_sort_column?
      @can_sort = true if @options[:sort] and model_have_column?(@options[:sort_as] || @ask)
    end
  
    # Set default options for cell
    # Set an empty hash if no html options
    # Set an empty hash if no options
    # Set sort to true if no options sort
    def set_default_options
      @html_options = {} unless defined? @html_options
      @options = {} unless defined? @options
      @html_options = format_options_to_cell(@html_options, @options)
      @options[:sort] = @@options[:sort] if !@options.has_key? :sort
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
    def sort_link_to(name, sort_on)
      create_link_to(name, sort_url(sort_on), @@options[:sort_remote])
    end
  
    # Create the link based on object
    # Set an ajax link if option link_remote is set to true
    # Compatible with rails 2 and 3.
    def create_link_to(block, url, remote, method = nil, confirm = nil)
      if remote and Tools::rails3?
        return link_to(block, url, :method => method, :confirm => confirm, :remote => true)
      elsif remote
        method = :get if method.nil?
        return link_to_remote(block, { :url => url, :method => method, :confirm => confirm })
      end
      link_to(block, url, :method => method, :confirm => confirm)
    end
  
    # Return a string with html class of sorting for headers
    # The html class is based on option: SortingTableFor::TableBuilder.html_sorting_class
    def sorting_html_class(sort_on)
      return TableBuilder.html_sorting_class.first if current_sorting(sort_on).nil?
      return TableBuilder.html_sorting_class.second if current_sorting(sort_on) == :asc
      TableBuilder.html_sorting_class.third
    end
  
    # Return an url for sorting
    # Add the param sorting_table[name]=direction to the url
    # Add the default direction: :asc
    def sort_url(sort_on)
      url_params = @@params.clone
      if url_params.has_key? TableBuilder.params_sort_table
        if url_params[TableBuilder.params_sort_table].has_key? sort_on
          url_params[TableBuilder.params_sort_table][sort_on] = inverse_sorting(sort_on)
          return url_for(url_params)
        end
        url_params[TableBuilder.params_sort_table].delete sort_on
      end
      url_params[TableBuilder.params_sort_table] = { sort_on => :asc }
      url_for(url_params)
    end
  
    # Return a symbol of the current sorting (:asc, :desc, nil)
    def current_sorting(sort_on)
      if @@params.has_key? TableBuilder.params_sort_table and @@params[TableBuilder.params_sort_table].has_key? sort_on
        return @@params[TableBuilder.params_sort_table][sort_on].to_sym
      end
      nil
    end
  
    # Return a symbol, the inverse of the current sorting
    def inverse_sorting(sort_on)
      return :asc if current_sorting(sort_on).nil?
      return :desc if current_sorting(sort_on) == :asc
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