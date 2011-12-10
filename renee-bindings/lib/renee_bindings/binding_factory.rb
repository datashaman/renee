module Renee
  module Bindings
    class BindingFactory
      attr_reader :adapters, :bindings

      def initialize
        @adapters = {}
        @bindings = {}
      end

      def add_adapter(name, adapter)
        factory = self
        @adapters[name] = adapter
      end

      def bind(name, type = nil)
        raise "Unknown binding #{name.inspect}" unless @bindings.key?(name)
        binding = Binding.new(self, &@bindings[name])
        binding.validate_type = type if type
        binding
      end

      def bind_object(name)
        bind(name, :object)
      end

      def bind_list(name)
        bind(name, :list)
      end

      def run(&blk)
        # later!
      end

      def binding(n, &blk)
        factory = self
        bindings[n] = blk
      end
    end
  end
end