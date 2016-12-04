module Pastor
  module Metadata
    module Collection < Form
      def get(item)
        return instance_variable_get("@#{name}") if instance_variable_defined?("@#{name}")

        nested_model = model.send(name) unless model.nil?

        if nested_klass.metadata.collection?
          nested_form = Collection.new(self, nested_klass, nested_model)
        else
          nested_form = nested_klass.new(self, nested_model)
        end

        instance_variable_set("@#{name}", nested_form)
      end

      def set(item, value)
      end

      def get_attributes(item)
      end

      def set_attributes(item, value)
        send(name).assign_attributes(attributes)
      end
    end
  end
end
