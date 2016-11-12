module Pastor
  class Metadata
    attr_reader :item, :options

    attr_accessor :name, :parent, :fields, :nested_forms

    OPTIONS = %i(collection form)
    attr_accessor *OPTIONS

    alias_method :collection?, :collection

    def initialize(item)
      @item = item; @fields = []; @nested_forms = {}
    end

    def options=(options)
      return unless options.present?

      @options = options.symbolize_keys.slice(*OPTIONS)

      @options.each do |option, value|
        send("#{option}=", value)
      end
    end

    def form=(klass)
      @fields += klass.metadata.fields
      @nested_forms.merge!(klass.metadata.nested_forms)
    end

    def for_instance(item)
      metadata = Metadata.new(item)

      metadata.name = name
      metadata.fields = fields
      metadata.options = options

      metadata.nested_forms = nested_forms.map do |name, klass|
        item.send(name)
      end

      metadata
    end
  end
end
