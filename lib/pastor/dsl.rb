module Pastor
  module DSL
    def self.metadata
      @metadata ||= Pastor::Metadata.new(self)
    end

    # ########################
    # Model

    def model(name, klass)
      handler = metadata.model(name, klass)
    end

    # ########################
    # Field

    def field(name, options)
      handler = metadata.filed(name, options)

      define_accessor(name, handler)
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
      handler = metadata.nested_form(name, options, &block)

      define_accessor(name, handler)
      define_attributes_accessor(name, handler)
    end

    def nested_forms(name, options = {}, &block)
      handler = metadata.nested_form(name, options, &block)
      #handler = Handler::Collection.new(name, options, &block)

      define_accessor(name, handler)
      define_attributes_accessor(name, handler)
    end

    # ########################
    # Define Accessors

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
