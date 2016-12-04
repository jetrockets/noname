module Pastor
  module DSL
    # ########################
    # Model

    def model(name, klass)
      meta = Metadata::Model.new(name, klass)
    end

    # ########################
    # Field

    def field(name, options)
      meta = Metadata::Field.new(name, options)

      define_accessor(name, meta)
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
      meta = Metadata::Form.new(name, options, &block)

      define_accessor(name, meta)
      define_attributes_accessor(name, meta)
    end

    def nested_forms(name, options = {}, &block)
      meta = Metadata::Collection.new(name, options, &block)

      define_accessor(name, meta)
      define_attributes_accessor(name, meta)
    end

    # ########################
    # Define Accessors

    def define_accessor(name, meta)
      define_method(name) do
        if instance_variable_defined?("@#{name}")
          return instance_variable_get("@#{name}") 
        end
        
        form.instance_variable_set("@#{name}", meta.get(self))
      end

      define_method("#{name}=") do |value|
        item.instance_variable_set("@#{name}", meta.set(self, value))
      end
    end

    def define_attributes_accessor(name, meta)
      define_method("#{name}_attributes") do
        meta.get_attributes(self)
      end

      define_method("#{name}_attributes=") do |attributes|
        meta.set_attributes(self, attributes)
      end
    end
  end
end
