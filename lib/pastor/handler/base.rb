module Pastor
  module Handlers
    class Base
      attr_reader :name, :options, :block

      def initialize(name, options = {}, &block)
        @name = name; @options = options; @block = block
      end

      def set(form, value)
      end

      def get(form)
      end

      protected

      def define_accessor(name, handler)
        define_method(name) do
          if instance_variable_defined?("@#{name}")
            return instance_variable_get("@#{name}")
          end

          form.instance_variable_set("@#{name}", handler.get(self))
        end

        define_method("#{name}=") do |value|
          item.instance_variable_set("@#{name}", handler.set(self, value))
        end
      end

      def define_attributes_accessor(name, handler)
        define_method("#{name}_attributes") do
          handler.get_attributes(self)
        end

        define_method("#{name}_attributes=") do |attributes|
          handler.set_attributes(self, attributes)
        end
      end
    end
  end
end
