module Noname
  module Translation
    def i18n_scope
      :forms
    end

    def attributes_scope
      @scope ||= if metadata.parent.blank?
        name.underscore
      else
        "#{metadata.parent.attributes_scope}.#{metadata.name}"
      end
    end

    def human_attribute_name(attribute, options = {})
      I18n.translate("#{i18n_scope}.#{attributes_scope}.#{attribute}", **options)
    end

    def model_name
      ActiveModel::Name.new(self, nil, _name)
    end

    # FIXME
    def _name
      (metadata.parent && metadata.parent._name) || name
    end
  end
end
