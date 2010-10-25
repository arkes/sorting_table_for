# encoding: utf-8

module SortingTableModelScope
  
  def self.included(base)
    base.extend(SingletonMethods)
  end
  
  module SingletonMethods

    def sorting_table(*args)
      raise ArgumentError, 'sorting_table: Too many arguments (max : 3)' if args.size > 3 
      sort_table_param = get_sorting_table_params(args)
      return scoped({})  if !sort_table_param and args.size == 1
      sort, direction = get_sort_and_direction(sort_table_param, args)
      return scoped({}) if !sort or !valid_column?(sort) or !valid_direction?(direction)
      return scoped({ :order => "#{sort} #{direction}" })
    end

    private

    def get_sorting_table_params(args)
      return nil unless args.first.is_a? Hash      
      return nil unless args.first.has_key? SortingTableFor::TableBuilder.params_sort_table.to_s
      args.first[SortingTableFor::TableBuilder.params_sort_table.to_s]
    end
  
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
    
    def valid_column?(column)
      column_names.include? column.to_s.downcase
    end
    
    def valid_direction?(direction)
      %[asc desc].include? direction.to_s.downcase
    end
    
 end  
end

if defined? ActiveRecord
  ActiveRecord::Base.send :include, SortingTableModelScope
end
