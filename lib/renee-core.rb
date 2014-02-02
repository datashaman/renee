require 'rack'

require_relative './renee-core/version'
require_relative './renee-core/transform'
require_relative './renee-core/chaining'
require_relative './renee-core/exceptions'
require_relative './renee-core/rack_interaction'
require_relative './renee-core/routing'
require_relative './renee-core/responding'
require_relative './renee-core/plugins'

# Top-level Renee constant
module Renee
  # @example
  #     Renee.core { path('/hello') { halt :ok } }
  def self.core(&app)
    cls = Class.new(Renee::Core)
    cls.run(&app) if app
    cls
  end

  # The top-level class for creating core application.
  # For convience you can also used a method named #Renee
  # for decalaring new instances.
  class Core
    # Error raised if routing fails. Use #continue_routing to continue routing.
    NotMatchedError = Class.new(RuntimeError)

    # Error raised if respond! or respond is used and no body is set.
    NoResponseSetError = Class.new(RuntimeError)

    # Class methods that are included in new instances of {Core} 
    module ClassMethods
      include Plugins

      # The application block used to create your application.
      attr_reader :application_block

      # Provides a rack interface compliant call method. This method creates a new instance of your class and calls
      # #call on it.
      def call(env)
        new.call(env)
      end

      # Specify a middleware to use before calling your application.
      def use(mw, *args, &blk)
        middlewares << [mw, args, blk]
      end

      # Retreive the list of currently available middlewares.
      def middlewares
        @middlewares ||= []
      end

      # Allows you to set the #application_block on your class.
      # @yield The application block
      def run(&app)
        @application_block = app
        setup do
          register_variable_type :integer, Transform::IntegerMatcher
          register_variable_type :int, :integer
        end
      end

      # Runs class methods on your application.
      def setup(&blk)
        instance_eval(&blk)
        self
      end

      # The currently available variable types you've defined.
      def variable_types
        @variable_types ||= {}
      end

      # Registers a new variable type for use within {Renee::Core::Routing#variable} and others.
      # @param [Symbol] name The name of the variable.
      # @param [Regexp] matcher A regexp describing what part of an arbitrary string to capture.
      # @return [Renee::Core::Matcher] A matcher
      def register_variable_type(name, matcher)
        matcher = case matcher
        when Transform::Matcher then matcher
        when Array              then Transform::Matcher.new(matcher.map{|m| variable_types[m]})
        when Symbol             then variable_types[matcher]
        else                         Transform::Matcher.new(matcher)
        end
        matcher.name = name
        variable_types[name] = matcher
      end
    end

    attr_reader :env, :request, :detected_extension

    # Provides a rack interface compliant call method.
    # @param[Hash] env The rack environment.
    def call(e)
      initialize_plugins
      idx = 0
      next_app = proc do |env|
        if idx == self.class.middlewares.size
          @requested_http_methods = []
          @env, @request = env, Rack::Request.new(env)
          @detected_extension = env['PATH_INFO'][/\.([^\.\/]+)$/, 1]
          # TODO clear template cache in development? `template_cache.clear`
          out = catch(:halt) do
            begin
              self.class.before_blocks.each { |b| instance_eval(&b) }
              instance_eval(&self.class.application_block)
              raise NotMatchedError
            rescue ClientError => e
              e.response ? instance_eval(&e.response) : halt("There was an error with your request", 400)
            rescue NotMatchedError => e
              unless @requested_http_methods.empty?
                throw :halt, 
                  Rack::Response.new(
                    "Method #{request.request_method} unsupported, use #{@requested_http_methods.join(", ")} instead", 405,
                    {'Allow' => @requested_http_methods.join(", ")}).finish
              end
            end
            Rack::Response.new("Not found", 404).finish
          end
          self.class.after_blocks.each { |a| out = instance_exec(out, &a) }
          out
        else
          middleware = self.class.middlewares[idx]
          idx += 1
          middleware[0].new(next_app, *middleware[1], &middleware[2]).call(env)
        end
      end
      next_app[e]
    end # call

    def initialize_plugins
      self.class.init_blocks.each { |init_block| self.class.class_eval(&init_block) }
      self.class.send(:define_method, :initialize_plugins) { }
    end

    include Chaining
    include Routing
    include Responding
    include RackInteraction
    include Transform

    extend ClassMethods
  end
end
