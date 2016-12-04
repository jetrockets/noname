module Pastor
  module Form
    module Model
      def process_model
        if destroy_model?
          destroy_model
        else
          update_model
        end

        nested_forms.each do |form|
          form.process_model
        end
      end

      def process_model!
        process_model and model.save
      end

      def build_model
        return if parent.model.nil?

        if metadata.collection?
          parent.model.send(metadata.name).build
        else
          parent.model.send("build_#{metadata.name}")
        end
      end

      def update_model
        return unless update_model?
        build_model! if model.nil?

        fields.each do |field|
          model.send("#{field}=", send(field))
        end
      end

      def destroy_model
        model.mark_for_destruction if model.present?
      end

      def build_model!
        @model = build_model
      end

      def update_model!
        update_model and model.save
      end

      def destroy_model!
        model.destroy if model.present?
      end

      def update_model?
        true
      end

      def destroy_model?
        _destroy.to_b
      end
    end
  end
end
