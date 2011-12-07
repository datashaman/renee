require 'multi_json'

require "renee_bindings/version"
require 'renee_bindings/adapters'

module Renee
  module Bindings
    class Binding
      attr_accessor :from, :to_class, :to

      def execute
        instance_eval(&self.class._binding_blk)
        self
      end

      def attr(name)
        @to ||= to_class.create_object
        to.set_attr(name, from.get_attr(name))
      end

      def list(name, binding, &blk)
        @to ||= to_class.create_object
        bind = self.class._binding_factory.bindings[binding].new
        from_array = @from.get_attr(name)
        bind.to_class = to_class
        to_array = bind.to_class.create_list
        from_array.get_list_size.times do |i|
          bind.to = nil
          bind.from = from_array.get_list_item(i)
          bind.execute
          to_array.set_list_item(i, bind.to.obj)
        end
        @to.set_attr(name, to_array.obj)
      end
    end

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
          response.first.send(response.last, *args, &blk)
        else
          super
        end
      end

      def decode_method(m)
        split_m = m.to_s.split(/_/, 2)
        case split_m.first
        when 'from'
          if reader = @adapters[split_m.last.to_sym]
            puts "using from_obj ... "
            return [reader, :new]
          end
        when 'to'
          if emitter = @adapters[split_m.last.to_sym]
            return [emitter, :to_native]
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

    DefaultFactory = BindingFactory.new
  end

  Bindings::DefaultFactory.add_adapter(:json, Bindings::Adapters::JSONAdapter)
  Bindings::DefaultFactory.add_adapter(:ruby, Bindings::Adapters::RubyAdapter)
  Bindings::DefaultFactory.add_adapter(:hash, Bindings::Adapters::PrimitiveAdapter)
end
