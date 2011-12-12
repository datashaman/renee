module Renee
  module Bindings
    module Binding
      class BaseBinding
        attr_accessor :to_class, :to, :from
        attr_reader :binding_block

        def initialize(factory, creator = nil, &blk)
          @factory, @creator, @binding_block = factory, creator, blk
        end

        def method_missing(m, *args, &blk)
          method_s = m.to_s
          case method_s
          when /(from|wrap)_([^_]+)_(.*)$/
            @from = @factory.adapters[$2.to_sym].send(:"from_#{$3}", *args, &blk)
            $1 == 'wrap' ? @from : self
          when /(from|wrap)_([^_]+)$/
            adapter = @factory.adapters[$2.to_sym]
            @from = if adapter.respond_to?(:decode)
              adapter.decode(*args, &blk)
            else
              adapter.create(*args, &blk)
            end
            $1 == 'wrap' ? @from : self
          when /as_([^_]+)$/
            raise unless @from
            @to_class = @factory.adapters[$1.to_sym]
            raise unless @to_class
            execute
            to_representation = if @to.respond_to?(:encode)
              @to.encode(*args, &blk)
            else
              @to.obj
            end
            to_representation
          else
            super
          end
        end
      end

      class IndeterminateBinding < BaseBinding
        def initialize(factory, binding_name)
          @factory = factory
          @binding_name = binding_name
        end

        def execute
          binding = if @from.is_a?(Adapters::BaseAdapter)
            case @from.type
            when :list
              binding_name = @binding_name
              binding = ArrayBinding.new(@factory) do
                all_elements binding_name
              end
            when :object
              binding = @factory.bind_object(@binding_name)
            end
          else
            binding = @factory.bind_primitive(@binding_name)
          end
          binding.to_class = @to_class
          binding.from = @from
          binding.execute
          @to = binding.to
        end
      end
    end
  end
end
