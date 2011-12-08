module Renee
  module Bindings
    module Adapters
      class PrimitiveAdapter < BaseAdapter
        include ArrayObjAdapter

        attr_reader :obj

        def self.create_list
          new(Array.new)
        end

        def self.create_object
          new(Hash.new)
        end

        def self.type
          "primitive"
        end

        def initialize(obj)
          @obj = obj
        end

        def set_attr(name, value)
          raise if list?
          @obj[name.to_sym] = value
        end

        def get_attr(name)
          raise if list?
          wrap(@obj[name.to_sym])
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
    end
  end
end
