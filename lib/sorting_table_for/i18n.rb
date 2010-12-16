# encoding: utf-8

module SortingTableFor
  module I18n    
    class << self
      
      # Set options to create a default scope
      def set_options(params, model_name, i18n_active = true)
        @model_name, @i18n_active = model_name, i18n_active
        @action = (params.has_key? :action) ? params[:action].downcase : ''
        @controller = (params.has_key? :controller) ? params[:controller].downcase : ''
        if @controller.include? '/'
          @namespace = @controller.split '/'
          @controller = @namespace.pop
        end
      end
      
      # Add a default scope if option scope isn't defined
      def translate(attribute, options = {}, type = nil)
        unless @i18n_active
          return options[:value] if options.has_key? :value
          return attribute
        end
        unless options.has_key? :scope
          options[:scope] = create_scope
          options[:scope] << TableBuilder.i18n_add_header_action_scope if type and type == :header
          options[:scope] << TableBuilder.i18n_add_footer_action_scope if type and type == :footer
          options[:scope] << options.delete(:add_scope)
          options[:scope].flatten!
        end
        ::I18n.t(attribute, options)
      end
      alias :t :translate
      
      private
      
      # Return an array with the scope based on option: SortingTableFor::TableBuilder.i18n_default_scope
      def create_scope
        return TableBuilder.i18n_default_scope.collect do |scope_value|
          case scope_value.to_sym
            when :controller then @controller
            when :action then @action
            when :model then @model_name ? @model_name.downcase.to_s : ''
            when :namespace then @namespace ? @namespace : ''
            else scope_value.to_s
          end
        end
      end
      
    end
  end
end
