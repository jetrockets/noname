module Pastor
  module DSL
    def self.metadata
      @metadata ||= Pastor::Metadata.new(self)
    end

    # ########################
    # Model

    def model(name, klass)
      metadata.model(name, klass)
    end

    # ########################
    # Field

    def field(name, options)
      metadata.field(name, options)
    end

    def fields(*names)
      options = names.pop if names.last.is_a?(Hash)

      names.each do |name|
        metadata.field(name, options || {})
      end
    end

    # ########################
    # Nested Forms

    def nested_form(name, options = {}, &block)
      metadata.nested_form(name, options, &block)
    end

    def nested_forms(name, options = {}, &block)
      metadata.nested_form(name, options, &block)
      #Handler::Collection.new(name, options, &block)
    end
  end
end
