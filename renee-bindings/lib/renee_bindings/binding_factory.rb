module Renee
  module Bindings
    class BindingFactory
      attr_reader :adapters, :bindings

      class BindingData
        attr_accessor :type, :generator, :block
        def initialize(type, generator = nil, &block)
          @type, @generator, @block = type, generator, block
        end
      end

      def initialize
        @adapters = {}
        reset!
      end

      def add_adapter(name, adapter)
        factory = self
        @adapters[name] = adapter
      end

      def reset!
        @bindings = {}
      end

      def bind(name, type = nil)
        binding_data = @bindings[name]
        raise "Unknown binding #{name.inspect}" unless binding_data
        if type == nil or (type == :list && binding_data.type != type)
          Binding::IndeterminateBinding.new(self, name)
        else
          binding_class = case binding_data.type
          when :list    then Binding::ArrayBinding
          when :object  then Binding::ObjectBinding
          when :literal then Binding::LiteralBinding
          else               raise "Unknown binding type #{binding_data.type}"
          end
          binding_class.new(self, binding_data)
        end
      end

      def greedy_array_binding(name)
        data = BindingData.new(:list) { all_elements name }
        Binding::ArrayBinding.new(self, data)
      end

      def bind_data(name)
        @bindings[name] or raise "Unknown binding #{name.inspect}"
      end

      def set_ruby_generator(name, &blk)
        bindings[name].generator = blk
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
        bindings[n] = BindingData.new(:object, &blk)
      end

      def literal_binding(n, &blk)
        bindings[n] = BindingData.new(:literal, &blk)
      end

      def array_binding(n, &blk)
        bindings[n] = BindingData.new(:list, &blk)
      end
    end
  end
end