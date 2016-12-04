module Pastor
  module Metadata
    module Form
      attr_reader :name, :options, :klass

      def initialize(name, options, &block)
        @name = name; @options = options; @klass = define_klass(&block)

        metadata.nested_forms[name] = klass

        define_nested_validations(name)
      end

      def get(item)
        if item.instance_variable_defined?("@#{name}")
          return item.instance_variable_get("@#{name}") 
        end

        nested_model = item.send(name) unless item.nil?
        nested_form = nested_klass.new(self, nested_model)

        item.instance_variable_set("@#{name}", nested_form)
      end

      def set(item, value)
      end

      def get_attributes(item)
      end

      def set_attributes(item, value)
        send(name).assign_attributes(attributes)
      end

      protected

      def define_klass(&block)
        parent = self

        Class.new(options[:form] || Pastor::Form) do
          # ?
          metadata.name = name
          metadata.parent = parent
          metadata.options = options

          # ?
          def initialize(parent, model, attributes = {})
            @parent = parent
            super(model, attributes)
          end

          class_eval(&block) if block_given?
        end
      end

      def define_nested_validations(name)
        validate do |form|
          nested_form = form.send(name)
          next unless nested_form.update_model?

          unless nested_form.valid?
            nested_form.errors.messages.each do |nested_attribute, nested_errors|
              errors.set(:"#{name}.#{nested_attribute}", nested_errors)
            end
          end
        end
      end
    end
  end
end
