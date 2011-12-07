module Renee
  module Bindings
    module Adapters
      class JSONAdapter < PrimitiveAdapter
        def self.decode(str)
          new MultiJson.decode(str)
        end

        def encode
          MultiJson.encode(@obj)
        end
      end
    end
  end
end
