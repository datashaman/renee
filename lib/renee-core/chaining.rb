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
        def initialize(target, method, args = nil)
          @target, @calls = target, []
          @calls << [method, args]
        end

        def method_missing(method, *args, &blk)
          @calls << [method, args]
          klass = @target.class
          if blk.nil? && klass.respond_to?(:chainable?) && klass.chainable?(method)
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
                args = call.at(1) || []
                ret = @target.send(call.at(0), *args, &callback)
              end
            end
            ret = callback.call
            ret
          end
        end
      end

      # @private
      module ClassMethods
        def chainable?(method)
          method_defined?(:"#{method}_chainable")
        end

        def chainable(*methods)
          methods.each do |method|
            define_method(:"#{method}_chainable") { }
          end
        end
      end

      def create_chain_proxy(method_name, *args)
        ChainingProxy.new(self, method_name, args)
      end

      def self.included(object)
        object.extend(ClassMethods)
      end
    end
  end
end
