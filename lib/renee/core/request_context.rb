module Renee
  class Core
    # This module deals with the Rack#call compilance. It defines #call and also defines several critical methods
    # used by interaction by other application modules.
    module RequestContext
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
                    Renee::Core::Response.new(
                      "Method #{request.request_method} unsupported, use #{@requested_http_methods.join(", ")} instead", 405,
                      {'Allow' => @requested_http_methods.join(", ")}).finish
                end
              end
              Renee::Core::Response.new("Not found", 404).finish
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
    end
  end
end
