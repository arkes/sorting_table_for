module SortingTableFor
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

    # Return a tr line based on the type (:thead, :tbody or :tfoot) 
    def render_line
      if @type == :thead
        return content_tag(:tr, Tools::html_safe(@cells.collect { |cell| cell.render_cell_thead }.join), @html_options)
      elsif @type == :tfoot
        return content_tag(:tr, Tools::html_safe(@cells.collect { |cell| cell.render_cell_tfoot }.join), @html_options)
      else
        content_tag(:tr, Tools::html_safe(@cells.collect { |cell| cell.render_cell_tbody }.join), @html_options.merge(:class => "#{@html_options[:class]} #{@@template.cycle(:odd, :even)}".strip))
      end
    end

    # Return the number of cells in line
    def total_cells
      @cells.size
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

    # Options only for cells
    def only_cell_option?(key)
      [:colspan].include? key
    end

    # Format ask to send options to cell
    def format_options_to_cell(ask, options = @column_options)
      options.each do |key, value|
        if only_cell_option?(key)
          if ask.is_a? Hash
            ask.merge!(key => value)
          else            
            ask = [ask] unless ask.is_a? Array
            (ask.last.is_a? Hash and ask.last.has_key? :html) ? ask.last[:html].merge!(key => value) : ask << { :html =>  { key => value }} 
          end
        end
      end
      ask
    end

    private

    # Call after headers or columns with no attributes (table.headers)
    # Create all the cells based on each column in the model's database table
    # Create cell's actions based on option default_actions or on actions given (:actions => [:edit])
    def create_cells
      @attributes.each { |ask| add_cell(@object, format_options_to_cell(ask)) }
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
end