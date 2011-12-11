module Renee
  module Bindings
    module Adapters
      class BaseAdapter
        def self.list(list)
          raise
        end

        def self.object(attrs)
          raise
        end

        attr_reader :obj
        def initialize(obj)
          @obj = obj
        end
      end

      module TypedAccessors
        def get_object(name)
          obj = self.class.create(get(name))
          raise if obj.list?
          obj
        end

        def get_list(name)
          obj = self.class.create(get(name))
          raise unless obj.list?
          obj
        end

        def get_int(name)
          case obj = get(name)
          when Integer then obj
          else              raise
          end
        end

        def get_float(name)
          case obj = get(name)
          when Numeric then obj
          else              raise "obj is #{obj.inspect}"
          end
        end
      end

      module ArrayHelper
        include TypedAccessors
        def list?
          true
        end

        def size
          @obj.size
        end

        def set(i, value)
          @obj[i] = value
        end
          
        def get(i)
          @obj.at(i)
        end
      end

      module HashHelper
        include TypedAccessors

        def list?
          false
        end

        def key?(k)
          @obj.key?(k)
        end

        def get(k)
          @obj[k.to_sym]
        end

        def set(k, v)
          @obj[k.to_sym] = v
        end
      end

    end
  end
end
