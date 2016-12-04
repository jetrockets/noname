module Pastor
  class Form
    extend Pastor::DSL
    extend Pastor::Translation

    include Pastor::Validations

    attr_reader :model, :attributes

    def initialize(model, attributes = {})
      @model = model; @attributes = attributes
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
