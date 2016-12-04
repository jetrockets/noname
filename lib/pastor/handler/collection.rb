module Pastor
  module Handler
    module Collection < Form
      def get(form)
        Collection.new(form, klass, form.model.send(name))
      end

      def set(form, value)
      end

      def get_attributes(form)
      end

      def set_attributes(form, value)
        send(name).assign_attributes(attributes)
      end
    end
  end
end
