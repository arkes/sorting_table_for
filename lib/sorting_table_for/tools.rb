# encoding: utf-8

module SortingTableFor
  module Tools
    extend self
    
    ##
    ## This module is a copy from Formtastic : http://github.com/justinfrench/formtastic
    ##
    
    ## Rails XSS Safety

    # Returns the given text, marked as being HTML-safe.
    # With older versions of the Rails XSS-safety mechanism,
    # this destructively modifies the HTML-safety of `text`.
    #
    # @param text [String]
    # @return [String] `text`, marked as HTML-safe
    def html_safe(text)
      return text if !text
      return text.html_safe if defined?(ActiveSupport::SafeBuffer)
      return text.html_safe! if text.respond_to?(:html_safe!)
      text
    end

    def rails_safe_buffer_class
      # It's important that we check ActiveSupport first,
      # because in Rails 2.3.6 ActionView::SafeBuffer exists
      # but is a deprecated proxy object.
      return ActiveSupport::SafeBuffer if defined?(ActiveSupport::SafeBuffer)
      return ActionView::SafeBuffer
    end
    
  end
end
