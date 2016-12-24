module Pastor
  class Metadata
    attr_reader :form, :model, :fields, :nested_forms

    def initialize(form)
      @form = form; @model = nil

      @fields = {}; @nested_forms = {}
    end

    # ?
    def register(type, handler)
      case type
        when :model
          @model = handler
        when :field
          fields[handler.name] = handler
        when :nested_form
          nested_forms[handler.name] = handler
      end
    end
  end
end
