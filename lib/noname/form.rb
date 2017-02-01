module Noname
  class Form
    include ::ActiveModel::Validations

    extend Noname::Field
    extend Noname::NestedForm

    extend Noname::Translation

    attr_reader :parent, :model

    attr_accessor :_destroy

    def initialize(model, attributes = {})
      @model = model#|| build_model

      assign_attributes(attributes)
    end

    def process
      process_model! if valid?
    end

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

    def errors=(values)
      values.each do |name, error|
        errors.add(name, error)
      end
    end

    def attributes
      hash = {}

      fields.each do |field|
        hash[field] = send(field)
      end

      nested_forms.each do |form|
        hash["#{form.metadata.name}_attributes"] = form.attributes
      end

      hash
    end

    def assign_attributes(attributes)
      return unless attributes.present?

      attributes.each do |attribute, value|
        send("#{attribute}=", value) if respond_to?("#{attribute}=")
      end
    end

    def metadata
      @metadata ||= self.class.metadata.for_instance(self)
    end

    %i(fields nested_forms).each do |method|
      define_method method do
        metadata.send(method)
      end
    end

    %i(id persisted? new_record? marked_for_destruction?).each do |method|
      define_method method do
        model.send(method) unless model.nil?
      end
    end
  end
end
