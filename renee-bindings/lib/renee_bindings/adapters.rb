require 'ostruct'

module Renee
  module Bindings
    module Adapters
      class PrimitiveAdapter
        attr_reader :obj

        def self.decode(str)
          new(eval(str))
        end

        def self.create_list
          new(Array.new)
        end

        def self.create_object
          new(Hash.new)
        end

        def initialize(obj)
          @obj = obj
        end

        def list?
          @obj.is_a?(Array)
        end

        def set_attr(name, value)
          raise if list?
          @obj[name.to_sym] = value
        end

        def get_attr(name)
          raise if list?
          wrap(@obj[name.to_sym])
        end

        def set_list_item(idx, value)
          raise unless list?
          @obj[idx] = value
        end

        def get_list_item(idx)
          raise unless list?
          wrap(self.class.new(@obj[idx]))
        end

        def get_list_size
          raise unless list?
          @obj.size
        end

        def encode
          @obj.inspect
        end

        def bind_with(binding_name)
          @binding = self.class._binding_factory.bindings[binding_name].new
          @binding.from = self
          self
        end

        def method_missing(m, *args, &blk)
          if result = self.class._binding_factory.decode_method(m)
            @binding.to_class = result.first
            @binding.execute
            to_representation = @binding.to.send(result.last)
            @binding.to = nil
            to_representation
          else
            super
          end
        end

        def wrap(val)
          case val
          when Array, Hash
            self.class.new(val)
          else
            val
          end
        end
      end

      class JSONAdapter < PrimitiveAdapter
        def self.decode(str)
          new MultiJson.decode(str)
        end

        def encode
          MultiJson.encode(@obj)
        end
      end

      class RubyAdapter < PrimitiveAdapter
        def self.create_list
          new(Array.new)
        end

        def self.create_object
          new(OpenStruct.new)
        end

        def self.decode(str)
          raise
        end

        def encode
          raise
        end

        def set_attr(name, value)
          @obj.send("#{name}=", value)
        end

        def get_attr(name)
          @obj.send(name)
        end
      end
    end
  end
end