module Noname
  module NestedForm
    def nested_form(name, options = {}, &block)
      klass = define_nested_klass(name, options, &block)

      metadata.nested_forms[name] = klass

      define_nested_methods(name, klass)
      define_nested_validations(name)
    end

    def nested_forms(name, options = {}, &block)
      nested_form(name, options.merge(:collection => true), &block)
    end

    def define_nested_klass(name, options, &block)
      parent = self

      Class.new(options[:form] || Form) do
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

    def define_nested_methods(name, nested_klass)
      define_method(name) do
        return instance_variable_get("@#{name}") if instance_variable_defined?("@#{name}")

        nested_model = model.send(name) unless model.nil?

        if nested_klass.metadata.collection?
          nested_form = Collection.new(self, nested_klass, nested_model)
        else
          nested_form = nested_klass.new(self, nested_model)
        end

        instance_variable_set("@#{name}", nested_form)
      end

      define_method("#{name}_attributes") do
        send(name).attributes
      end

      # Comment!
      define_method("#{name}_attributes=") do |attributes|
        send(name).assign_attributes(attributes)
      end
    end

    def define_nested_validations(name)
      validate do |form|
        nested_form = form.send(name)
        next unless nested_form.update_model?

        unless nested_form.valid?
          nested_form.errors.messages.each do |nested_attribute, nested_errors|
            errors.add(:"#{name}.#{nested_attribute}", nested_errors)
          end
        end
      end
    end

    def metadata
      @metadata ||= Noname::Metadata.new(self)
    end
  end
end
