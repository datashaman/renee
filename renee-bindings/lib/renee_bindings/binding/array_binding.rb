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
          bind.to_class = @to_class
          @from.size.times do |i|
            bind.to = nil
            bind.from = @from.get_object(i)
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
