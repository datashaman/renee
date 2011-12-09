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
        @adapters[name] = Class.new(adapter) do
          define_singleton_method(:_binding_factory) { factory }
        end
      end

      def method_missing(m, *args, &blk)
        if response = decode_method(m)
          create_method = if response.last.nil?
            response.first.respond_to?(:decode) ? :decode : :new
          else
            response.last
          end
          response.first.send(create_method, *args, &blk)
        else
          super
        end
      end

      def wrap(type, obj)
        wrapper = @adapters[type.to_sym]
        wrapper.respond_to?(:decode) ? wrapper.decode(obj) : wrapper.new(obj)
      end

      def respond_to?(m)
        !decode_method(m).nil? || super
      end

      def decode_method(m)
        split_m = m.to_s.split(/_/, 2)
        case split_m.first
        when 'from'
          if m = split_m.last.match(/^(.*?)_([^_]+)$/)
            reader = @adapters[m[1].to_sym]
            if reader.respond_to?("from_#{m[2]}")
              return [reader, :"from_#{m[2]}"]
            end
          end
          return [@adapters[split_m.last.to_sym], nil]
        when 'as'
          if emitter = @adapters[split_m.last.to_sym]
            return [emitter, nil]
          end
        end
        nil
      end

      def run(&blk)
        # later!
      end

      def binding(name, &blk)
        factory = self
        bindings[name] = Class.new(Binding) do
          define_singleton_method(:_binding_factory) { factory }
          define_singleton_method(:_binding_blk) { blk }
        end
      end
    end
  end
end