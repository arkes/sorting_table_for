# encoding: utf-8

module SortingTableFor
  module I18n    
    class << self
      
      def set_options(params, model_name, namespace)
        @params, @model_name, @namespace = params, model_name, namespace
      end
      
      def translate(attribute, options = {}, action_header = false)
        if !options.has_key? :scope
          options[:scope] = create_scope 
          options[:scope] << TableBuilder.i18n_add_header_action_scope if action_header
        end
        ::I18n.t(attribute, options)
      end
      alias :t :translate
      
      private

      def create_scope
        return TableBuilder.i18n_default_scope.collect do |scope_value|
          case scope_value.to_sym
            when :controller then @params[:controller] ? @params[:controller].downcase : ''
            when :action then @params[:action] ? @params[:action].downcase : ''
            when :model then @model_name ? @model_name.downcase.to_s : ''
            when :namespace then @namespace ? @namespace.downcase.to_s : ''
            else scope_value.to_s
          end
        end
      end
      
    end
  end
end
