module Renee
  module Bindings
    class BindingFactory
      attr_reader :adapters, :bindings

      BindingData = Struct.new(:binding_block, :ruby_object, :ruby_list)

      def initialize
        @adapters = {}
        reset!
      end

      def add_adapter(name, adapter)
        factory = self
        @adapters[name] = adapter
      end

      def reset!
        @bindings = Hash.new{|h, k| h[k] = BindingData.new}
      end

      def bind(name, type = nil)
        raise "Unknown binding #{name.inspect}" unless @bindings.key?(name)
        binding = Binding.new(self, @bindings[name])
        binding.validate_type = type if type
        binding
      end

      def bind_ruby_object(name, &blk)
        bindings[name].ruby_object = blk
      end
      
      def bind_ruby_list(name, &blk)
        bindings[name].ruby_list = blk
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
        bindings[n].binding_block = blk
      end
    end
  end
end