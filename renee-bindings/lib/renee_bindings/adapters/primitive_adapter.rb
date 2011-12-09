module Renee
  module Bindings
    module Adapters
      class PrimitiveAdapter < BaseAdapter
        include ArrayObjectAdapter

        def self.create_list
          new(Array.new)
        end

        def self.create_object
          new(Hash.new)
        end

        def self.type
          "primitive"
        end

        def set_attr(name, value)
          raise if list?
          @obj[name.to_sym] = value
        end

        def get_attr(name)
          raise if list?
          @obj[name.to_sym]
        end

        def get_object(name)
          self.class.new(get_attr(name))
        end
        alias_method :get_list, :get_object
      end
    end
  end
end
