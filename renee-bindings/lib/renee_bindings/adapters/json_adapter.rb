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
      end
    end
  end
end
