module Noname
  module Field
    def field(field, options = {})
      metadata.fields.add(field, options)

      define_accessor(field, options)
    end

    def fields(*fields, options = {})
      fields.each do |field|
        field(field, options)
      end
    end

    def define_accessor(field, options = {})
      define_method(field) do
        instance_variable_get("@#{field}") || model.send(field)
      end

      define_method("#{field}=") do |value|
        instance_variable_set("@#{field}", value)
      end
    end
  end
end
