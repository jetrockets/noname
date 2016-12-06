module Pastor
  class Form
    extend Pastor::DSL
    extend Pastor::Translation

    include Pastor::Validations

    attr_reader :model, :raw_attributes

    def initialize(model, attributes = {})
      @model = model; @raw_attributes = attributes
    end




    attr_accessor :_destroy

    def process
      process_model! if valid?
    end

    def assign_attributes(attributes)
      return unless attributes.present?

      attributes.each do |attribute, value|
        send("#{attribute}=", value) if respond_to?("#{attribute}=")
      end
    end

    %i(id persisted? new_record? marked_for_destruction?).each do |method|
      define_method method do
        model.send(method) unless model.nil?
      end
    end

    # ?
    def valid?
      nested_forms.each do |name, form|
        next if form.valid?

        form.errors.messages.each do |nested_attribute, nested_errors|
          errors.set(:"#{name}.#{nested_attribute}", nested_errors)
        end
      end

      super
    end

    def nested_forms
      @nested_forms ||= self.calss.metadata.nested_forms.keys.reduce({}) do |name|
        hash[name] = send(name)
      end
    end

    def fields
      self.class.metadata.fields.keys
    end
  end
end
