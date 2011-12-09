module Renee
  module Bindings
    module Adapters
      class JSONAdapter < PrimitiveAdapter
        def self.decode(str)
          new MultiJson.decode(str)
        end

        def self.type
          "json"
        end

        def encode
          MultiJson.encode(@obj)
        end

        def get_attr(name)
          @obj[name.to_s]
        end

        def set_attr(name, value)
          @obj[name.to_s] = value
        end

        def get_object(name)
          self.class.new(get_attr(name))
        end
        alias_method :get_list, :get_object
      end
    end
  end
end
