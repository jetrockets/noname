module Pastor
  module Metadata
    # Options:
    #   :map     => (true, false, :field)
    #   :default => (value, ->{})
    #   :type    => (class, ->{})
    module Field < Base
      def get(form)
        map(form) || default(form)
      end

      def set(form, value)
        typecast(form, value)
      end

      protected

      def map?
        options.has_key?(:map) && !!options[:map]
      end

      def default?
        options.has_key?(:default)
      end

      def typecast?
        options.has_key?(:type)
      end

      def map(form)
        return unless map?

        case options[:map]
        when TrueClass
          form.model.send(name)
        when String, Symbol
          form.model.send(options[:map])
        end
      end

      def default(form)
        return unless default?

        case options[:default]
        when Proc
          options[:default].call(form)
        else
          options[:default]
        end
      end

      def typecast(form, value)
        return value unless typecast?

        case options[:type]
        when Proc
          options[:type].call(form, value)
        when Class
          options[:type].new(value)
        else
          value
        end
      end
    end
  end
end
