module Renee
  class Core
    # Module for creating chainable methods. To use this within your own modules, first `include Chaining`, then,
    # mark methods you want to be available with `chain_method :method_name`.
    # @example
    #    module MoreRoutingMethods
    #      include Chaining
    #      def other_routing_method
    #        # ..
    #      end
    #      chain_method :other_routing_method
    #
    module Chaining
      # @private
      class ChainingProxy
        def initialize(target, m, args = nil)
          @target, @calls = target, []
          @calls << [m, args]
        end

        def method_missing(m, *args, &blk)
          @calls << [m, args]
          if blk.nil? && @target.class.respond_to?(:chainable?) && @target.class.chainable?(m)
            self
          else
            inner_args = []
            ret = nil
            callback = proc do |*callback_args|
              inner_args.concat(callback_args)
              if @calls.size == 0
                ret = blk.call(*inner_args) if blk
              else
                call = @calls.shift
                ret = call.at(1) ? @target.send(call.at(0), *call.at(1), &callback) : @target.send(call.at(0), &callback) 
              end
            end
            ret = callback.call
            ret
          end
        end
      end

      # @private
      module ClassMethods
        def chainable?(m)
          chainable_methods.include?(m)
        end

        def chainable(*methods)
          methods.each { |m| chainable_methods << m }
        end

        def chainable_methods
          class_variable_get(:@@chainable_methods)
        end
      end

      def create_chain_proxy(method_name, *args)
        ChainingProxy.new(self, method_name, args)
      end

      def self.included(o)
        o.class_variable_set(:@@chainable_methods, []) unless o.class_variable_defined?(:@@chainable_methods)
        o.extend(ClassMethods)
      end
    end
  end
end
