module Renee
  module Bindings
    module Adapters
      class RubyAdapter < BaseAdapter
        include ArrayObjectAdapter

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

        def get_object(name)
          self.class.new(get_attr(name))
        end
        alias_method :get_list, :get_object
      end
    end
  end
end