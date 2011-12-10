module Renee
  module Bindings
    module Adapters
      class RubyAdapter < BaseAdapter
        def self.list(list)
          RubyListAdapter.new(list)
        end

        def self.object(attrs)
          RubyObjectAdapter.new(OpenStruct.new(attrs))
        end

        def self.create(obj)
          obj.is_a?(Array) ? RubyListAdapter.new(obj) : RubyObjectAdapter.new(obj)
        end

        class RubyObjectAdapter < RubyAdapter
          include TypedAccessors

          def list?
            false
          end

          def keys
            @keys ||= @obj.methods.select{|m| m.name.to_s[/[^=\?]$/] && m.arity == 0}.map{|m| m.name}
          end

          def set(key, value)
            @obj.send("#{key}=", value)
          end
            
          def get(key)
            @obj.send(key)
          end
            
          def key?(key)
            @obj.respond_to?(key)
          end
        end

        class RubyListAdapter < RubyAdapter
          include ArrayHelper

          def initialize(list)
            @obj = list
          end
        end
      end
    end
  end
end
