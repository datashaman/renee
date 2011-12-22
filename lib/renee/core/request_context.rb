module Renee
  class Core
    # This module deals with the Rack#call compilance. It defines #call and also defines several critical methods
    # used by interaction by other application modules.
    module RequestContext
      attr_reader :env, :request, :detected_extension

      # Provides a rack interface compliant call method.
      # @param[Hash] env The rack environment.
      def call(env)
        @env, @request = env, Rack::Request.new(env)
        @detected_extension = env['PATH_INFO'][/\.([^\.\/]+)$/, 1]
        # TODO clear template cache in development? `template_cache.clear`
        catch(:halt) do
          begin
            instance_eval(&self.class.application_block)
          rescue ClientError => e
            e.response ? instance_eval(&e.response) : halt("There was an error with your request", 400)
          rescue NotMatchedError => e
            # unmatched, continue on
          end
          Renee::Core::Response.new("Not found", 404).finish
        end
      end # call
    end
  end
end
