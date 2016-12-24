module Pastor
  module Syntax
    extend Forwardable

    def metadata
      @metadata ||= Pastor::Metadata.new(self)
    end

    delegate [:model, :field, :fields, :nested_form, :nested_forms] => :dsl

    def dsl
      @dsl ||= DSL.new(self)
    end

    class DSL
      attr_reader :form, :metadata

      def initialize(form)
        @form = form; @metadata = form.metadata
      end

      # ########################
      # Model

      def model(name, klass)
        metadata.register(:model, Handler::Model.new(name, klass))
      end

      # ########################
      # Field

      def field(name, options)
        handler = Handler::Field.new(name, options, &block)

        define_accessor(handler)

        metadata.register(:field, handler)
      end

      def fields(*names)
        options = names.pop if names.last.is_a?(Hash)

        names.each do |name|
          field(name, options || {})
        end
      end

      # ########################
      # Nested Forms

      def nested_form(name, options = {}, &block)
        handler = Handler::Form.new(name, options, &block)

        define_accessor(handler)
        define_attributes_accessor(handler)

        metadata.register(:nested_form, handler)
      end

      def nested_forms(name, options = {}, &block)
        handler = Handler::Collection.new(name, options, &block)

        define_accessor(handler)
        define_attributes_accessor(handler)

        metadata.register(:nested_form, handler)
      end

      private

      def define_accessor(handler)
        form.define_method(handler.name) do
          if instance_variable_defined?("@#{handler.name}")
            return instance_variable_get("@#{handler.name}")
          end

          form.instance_variable_set("@#{handler.name}", handler.get(form))
        end

        form.define_method("#{handler.name}=") do |value|
          item.instance_variable_set("@#{handler.name}", handler.set(form, value))
        end
      end

      def define_attributes_accessor(handler)
        form.define_method("#{handler.name}_attributes") do
          handler.get_attributes(form)
        end

        form.define_method("#{handler.name}_attributes=") do |attributes|
          handler.set_attributes(form, attributes)
        end
      end
    end
  end
end
