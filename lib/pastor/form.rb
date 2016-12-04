module Pastor
  class Form
    include ::ActiveModel::Validations

    extend Pastor::DSL
    extend Pastor::Translation

    attr_reader :parent, :model, :attributes

    attr_accessor :_destroy

    def initialize(model, attributes = {})
      @model = model#|| build_model

      assign_attributes(attributes)
    end

    def process
      process_model! if valid?
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

    def metadata
      @metadata ||= Pastor::Metadata.new(self)
    end
  end
end
