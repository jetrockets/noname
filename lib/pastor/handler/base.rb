module Pastor
  module Handlers
    class Base
      attr_reader :name, :options, :block

      def initialize(name, options = {}, &block)
        @name = name; @options = options; @block = block
      end

      def set(form, value)
      end

      def get(form)
      end
    end
  end
end
