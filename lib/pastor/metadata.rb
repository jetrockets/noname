module Pastor
  class Metadata
    attr_reader :form, :fields, :nested_forms, :model

    def initialize(form)
      @form = form; @model = nil
      @fields = {}; @nested_forms = {}
    end

    def field(name, options, &block)
      fields[name] = Handler::Field.new(name, options, &block)
    end

    def nested_form(name, options, &blok)
      nested_forms[name] = Handler::Form.new(name, options, &block)
    end

    def model(name)
      handler = Handler::Model.new(name, klass)
    end
  end
end
