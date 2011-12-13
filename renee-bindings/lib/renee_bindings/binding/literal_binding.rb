module Renee
  module Bindings
    module Binding
      class LiteralBinding < BaseBinding
        def string(vals = nil)
          @to = @from.to_s
          raise unless vals.nil? || vals.include?(@to)
        end

        def execute
          instance_eval(&@data.binding_block)
          @to = @data.ruby_generator[@to] if @data.ruby_generator
          self
        end
      end
    end
  end
end
