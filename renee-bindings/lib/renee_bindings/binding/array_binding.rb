module Renee
  module Bindings
    module Binding
      class ArrayBinding < BaseBinding
        def initialize(factory, creator = nil, &blk)
          super
          @position = 0
        end

        def all_elements(type)
          bind = @factory.bind(type)
          bind_data = @factory.bind_data(type)
          bind.to_class = @to_class
          @from.size.times do |i|
            bind.to = nil
            case bind_data.binding_type
            when :list   then bind.from = @from.get_list(i)
            when :object then bind.from = @from.get_object(i)
            else              bind.from = @from.get(i)
            end
            bind.execute
            @attrs << bind.to
          end
        end

        def execute
          @attrs = []
          instance_eval(&binding_block)
          @to = to_class.list(@attrs, &@creator)
          self
        end
      end
    end
  end
end
