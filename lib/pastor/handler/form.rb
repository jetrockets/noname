module Pastor
  module Handler
    module Form
      attr_reader :klass

      def initialize(name, options, &block)
        super

        @klass = define_klass(&block)
      end

      def get(form)
        klass.new(form, form.model.send(name))
      end

      def set(form, value)
      end

      def get_attributes(form)
      end

      def set_attributes(form, value)
      end

      protected

      def define_klass(&block)
        Class.new(options[:form] || Pastor::Form) do
          attr_reader :parent

          def initialize(parent, model, attributes = {})
            @parent = parent; super(model, attributes)
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
