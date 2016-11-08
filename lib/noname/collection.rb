class Noname
  class Collection
    include Enumerable
    
    attr_reader :parent, :klass, :forms, :errors

    delegate :metadata, :to => :klass

    # Comment!
    alias_method :to_ary, :to_a

    def initialize(parent, klass, models)
      @parent = parent; @klass = klass; @models = models

      @forms = Array(models).map do |model| 
        klass.new(parent, model)
      end

      @errors = ActiveModel::Errors.new(self) 

      # FIXME
      build_form! if build_form?
    end

    def process
      process_model! if valid?
    end

    def each
      forms.each do |form|
        yield form if block_given?
      end
    end

    def valid?
      errors.clear

      forms.each do |form|
        next if form.valid?

        form.errors.messages.each do |form_attribute, form_errors|
          errors.set(form_attribute, (errors.get(form_attribute) || []) + form_errors)
        end
      end

      errors.empty?
    end

    def process_model
      forms.each(&:process_model)
    end

    def process_model!
      forms.each(&:process_model!)
    end

    def build_form
      klass.new(parent, nil)
    end

    def build_form!
      form = build_form
      forms << form
      form
    end

    def build_form?
      forms.blank?
    end

    def update_model
      forms.each(&:update_model)
    end

    def update_model!
      forms.each(&:update_model!)
    end

    def destroy_model
      forms.each(&:destroy_model)
    end

    def destroy_model!
      forms.each(&:destroy_model!)
    end

    # FIXME
    def assign_attributes(attributes)
      reload_forms!

      indexed_forms = forms.index_by(&:id)

      attributes.each do |index, form_attributes|
        id = form_attributes[:id] || form_attributes['id']

        if id.present?
          form = indexed_forms[id.to_i]
        else
          form = build_form!
        end

        form.assign_attributes(form_attributes)
      end

      # FIXME
      build_form! if build_form?
    end

    # FIXME
    def reload_forms!
      @forms = models.reload.map do |model|
        klass.new(parent, model)
      end
    end
    #
    def models
      @models ||= parent.model.send(metadata.name)
    end
  end
end
