module Renee
  module Bindings
    class BindingFactory
      attr_reader :adapters, :bindings

      BindingData = Struct.new(:binding_block, :ruby_generator, :binding_class, :binding_type)

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
        binding_data = @bindings[name]
        raise "Unknown binding #{name.inspect}" unless binding_data
        if type == nil or (type == :list && binding_data.binding_type != type)
          Binding::IndeterminateBinding.new(self, name)
        else
          binding_data.binding_class.new(self, binding_data)
        end
      end

      def greedy_array_binding(name)
        data = BindingData.new(proc{
          all_elements name
        }, nil, Binding::ArrayBinding, :list)
        Binding::ArrayBinding.new(self, data)
      end

      def bind_data(name)
        @bindings[name] or raise "Unknown binding #{name.inspect}"
      end

      def set_ruby_generator(name, &blk)
        bindings[name].ruby_generator = blk
      end

      def bind_object(name)
        bind(name, :object)
      end

      def bind_list(name)
        bind(name, :list)
      end

      def bind_primitive(name)
        bind(name, :primitive)
      end

      def run(&blk)
        # later!
      end

      def object_binding(n, &blk)
        b = bindings[n]
        b.binding_type = :object
        b.binding_block = blk
      end

      def literal_binding(n, &blk)
        b = bindings[n]
        b.binding_type = :literal
        b.binding_block = blk
      end
    end
  end
end