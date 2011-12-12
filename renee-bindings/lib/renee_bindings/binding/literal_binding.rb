module Renee
  module Bindings
    module Binding
      class LiteralBinding < BaseBinding
        def string(vals = nil)
          @to = @from.to_s
          raise unless vals.nil? || vals.include?(@to)
        end

        def execute
          instance_eval(&binding_block)
          @to = @creator[@to] if @creator
          self
        end
      end
    end
  end
end
