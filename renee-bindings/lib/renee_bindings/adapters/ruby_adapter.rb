module Renee
  module Bindings
    module Adapters
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