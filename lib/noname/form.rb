module Noname
  class Form
    attr_reader :parent, :model, :attributes

    delegate :fields, :nested_forms, :to => :metadata

    attr_accessor :_destroy

    delegate :id, :persisted?, :new_record?, :marked_for_destruction?, :to => :model, :allow_nil => true

    def initialize(model, attributes = {}, parent = nil)
      @model = model || build_model
      @parent = parent
      @attributes = attributes
    end

    def process
      return false unless valid?

      process_model!

      nested_forms.each do |form|
        form.process_model!
      end
    end

    def build_model
      return if parent.nil? || parent.model.nil?

      if metadata.collection?
        parent.model.send(metadata.name).build
      else
        parent.model.send("build_#{metadata.name}")
      end
    end

    def build_model!
      @model = build_model
    end

    def process_model
      if destroy_model?
        destroy_model
      else
        update_model
      end
    end

    def process_model!
      if destroy_model?
        destroy_model!
      else
        update_model!
      end
    end

    def update_model
      fields.each do |field|
        model.send("#{field}=", send(field))
      end
    end

    def update_model!
      update_model and model.save
    end

    def destroy_model
      model.mark_for_destruction
    end

    def destroy_model!
      model.destroy
    end

    def destroy_model?
      _destroy.to_b
    end

    def metadata
      @metadata ||= self.class.metadata.for_instance(self)
    end
  end
end
