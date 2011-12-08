module Renee
  module Bindings
    module Adapters
      class RubyAdapter < BaseAdapter
        include ArrayObjAdapter

        def self.create_list
          new(Array.new)
        end

        def self.create_object
          new(OpenStruct.new)
        end

        def self.type
          "ruby"
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