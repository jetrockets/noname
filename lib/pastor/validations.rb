require 'active_support'

require 'active_model/naming'
require 'active_model/callbacks'
require 'active_model/translation'

require 'active_model/validator'
require 'active_model/validations'

module Pastor
  module Validations
    included do
      include ::ActiveModel::Validations
    end
  end
end
