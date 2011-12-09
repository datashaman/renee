module Renee
  module Bindings
    module Adapters
      module ArrayObjectAdapter
        def list?
          @obj.is_a?(Array)
        end

        def set_list_item(idx, value)
          raise unless list?
          @obj[idx] = value
        end

        def get_list_item(idx)
          raise unless list?
          @obj[idx]
        end

        def get_list_object(idx)
          raise unless list?
          self.class.new(@obj[idx])
        end

        def get_list_list(idx)
          raise unless list?
          self.class.new(@obj[idx])
        end

        def get_list_size
          raise unless list?
          @obj.size
        end
      end

      class BaseAdapter
        attr_reader :obj

        def self.create_list
          raise
        end

        def self.create_object
          raise
        end

        def self.from_file(f)
          decode(File.read(f))
        end

        def initialize(obj)
          @obj = obj
        end

        def list?
          raise
        end

        def get_object(name, value)
          raise
        end

        def get_list(name, value)
          raise
        end

        def set_attr(name, value)
          raise
        end

        def has_attr?(name)
          raise
        end

        def get_attr(name)
          raise
        end

        def set_list_item(idx, value)
          raise
        end

        def get_list_item(idx)
          raise
        end

        def get_list_size
          raise
        end

        def bind_with(binding_name)
          @binding = self.class._binding_factory.bindings[binding_name].new
          @binding.from = self
          self
        end

        def method_missing(m, *args, &blk)
          if result = self.class._binding_factory.decode_method(m)
            @binding.to_class = result.first
            @binding.execute
            to_representation = if result.last
              @binding.to.send(result.last, *args, &blk)
            elsif @binding.to.respond_to?(:encode)
              @binding.to.encode(*args, &blk)
            else
              @binding.to.obj
            end
            @binding.reset!
            to_representation
          else
            super
          end
        end
      end
    end
  end
end
