# encoding: utf-8

module SortingTableModelScope
  
  # Include the methods in models
  def self.included(base)
    base.extend(SingletonMethods)
  end
  
  module SingletonMethods
    
    # Return a scope of the object with an order
    #
    # === Usage
    # 
    #  sorting_table(the params) - Sorting by the given parameters
    #  sorting_table(the params, column name) - Sort by the column name with direction ascending, if no parameters
    #  sorting_table(the params, column name, direction) - Sort by the column name with the given direction, if no parameters
    #
    # === Exemples
    #
    #  User.sorting_table(params)
    #  User.sorting_table(params, :username)
    #  User.sorting_table(params, :username, :desc)
    #
    def sorting_table(*args)
      raise ArgumentError, 'sorting_table: Too many arguments (max : 3)' if args.size > 3 
      sort_table_param = get_sorting_table_params(args)
      return scoped({})  if !sort_table_param and args.size == 1
      sort, direction = get_sort_and_direction(sort_table_param, args)
      return scoped({}) if !sort or !valid_column?(sort) or !valid_direction?(direction)
      scoped({ :order => "#{sort} #{direction}" })
    end

    private
    
    # Return the params for sorting table
    def get_sorting_table_params(args)
      return nil unless args.first.is_a? Hash
      return nil unless args.first.has_key? SortingTableFor::TableBuilder.params_sort_table.to_s
      args.first[SortingTableFor::TableBuilder.params_sort_table.to_s]
    end
    
    # Parse the params and return the column name and the direction
    def get_sort_and_direction(sort_table_param, args)
      if sort_table_param
        key = sort_table_param.keys.first rescue nil
        value = sort_table_param.values.first rescue nil
        return nil if !key.is_a?(String) or !value.is_a?(String)
        return key, value
      end
      return nil if args.size < 2
      return args[1], 'asc' if args.size == 2
      return args[1], args[2]
    end
    
    # Return true if the column name exist
    def valid_column?(column)
      column_names.include? column.to_s.downcase
    end
    
    # Return true if the direction exist
    def valid_direction?(direction)
      %[asc desc].include? direction.to_s.downcase
    end
    
 end  
end

if defined? ActiveRecord
  ActiveRecord::Base.send :include, SortingTableModelScope
end
