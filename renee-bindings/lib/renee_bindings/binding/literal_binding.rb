module Renee
  module Bindings
    module Binding
      class LiteralBinding < BaseBinding
        def string(vals = nil)
          @to = @from.to_s
          raise unless vals.nil? || vals.include?(@to)
        end

        def execute
          instance_eval(&@data.block)
          @to = @data.generator[@to] if @data.generator
          self
        end
      end
    end
  end
end
