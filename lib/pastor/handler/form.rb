module Pastor
  module Handler
    module Form
      attr_reader :klass

      def initialize(name, options, &block)
        super

        @klass = define_klass(&block)
      end

      def get(form)
        klass.new(form, form.model.send(name), form.raw_attributes[name])
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
    end
  end
end
