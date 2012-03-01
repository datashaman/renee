module Renee
  class Core
    # Collection of useful methods for responding within a {Renee::Core} app.
    module Responding
      # Codes used by Symbol lookup in interpret_response.
      # @example
      #   halt :unauthorized # would return a 401.
      #
      HTTP_CODES = {
        :ok => 200,
        :created => 201,
        :accepted => 202,
        :no_content => 204,
        :bad_request => 400,
        :unauthorized => 401,
        :payment_required => 402,
        :forbidden => 403,
        :not_found => 404,
        :method_not_found => 405,
        :not_acceptable => 406,
        :gone => 410,
        :error => 500,
        :not_implemented => 501}.freeze

      # Halts current processing to the top-level calling Renee application and uses that as a response.
      # @param [Object...] response The response to use.
      # @see #interpret_response
      def halt(*response)
        throw :halt, interpret_response(response.size == 1 ? response.first : response)
      end

      # Halts current processing to the top-level calling Renee application and uses that as a response.
      # This version of halt does not pass your response through #interpret_response.
      # @param [Object] response The response to use.
      # @see #interpret_response, #halt
      def halt!(response)
        throw :halt, response
      end

      ##
      # Creates a response by allowing the response header, body and status to be passed into the block.
      #
      # @param [Array] body The contents to return.
      # @param [Integer] status The status code to return.
      # @param [Hash] header The headers to return.
      # @param [Proc] &blk The response options to specify
      #
      # @example
      #  respond { status 200; body "Yay!" }
      #  respond("Hello", 200, "foo" => "bar")
      #
      def respond(response_body = nil, response_status = nil, response_headers = nil)
        body(response_body) if response_body
        status(response_status) if response_status
        headers(response_headers) if response_headers
        yield if block_given?
        raise NoResponseSetError unless @body or @status or @headers
        Rack::Response.new(@body || [], @status || 200, @headers || {})
      end

      def respond!(response_body = nil, response_status = nil, response_headers = nil, &blk)
        halt respond(response_body, response_status, response_headers, &blk)
      end

      def status(code)
        @status = code
      end

      def body(*args)
        @body ||= []
        @body.concat(args) unless args.empty?
        @body
      end

      def header(headers)
        @headers ||= {}
        headers.each do |k, v|
          @headers[k.to_s] = v.to_s
        end
      end
      alias_method :headers, :header

      # Interprets responses returns by #halt.
      #
      # * If it is a Symbol, it will be looked up in {HTTP_CODES}.
      # * If it is a Symbol, it will use Rack::Response to return the value.
      # * If it is a Symbol, it will either be used as a Rack response or as a body and status code.
      # * If it is an Integer, it will use Rack::Response to return the status code.
      # * Otherwise, #to_s will be called on it and it will be treated as a Symbol.
      #
      # @param [Object] response This can be either a Symbol, String, Array or any Object.
      #
      def interpret_response(response)
        case response
        when Array   then
          case response.size
          when 3 then response
          when 2 then Rack::Response.new(response[1], HTTP_CODES[response[0]] || response[0]).finish
          else raise "I don't know how to render #{response.inspect}"
          end
        when String  then Rack::Response.new(response).finish
        when Integer then Rack::Response.new("Status code #{response}", response).finish
        when Symbol  then interpret_response(HTTP_CODES[response] || response.to_s)
        when Proc    then response.call
        else              response # pass through response
        end
      end

      # Returns a rack-based response for redirection.
      # @param [String] path The URL to redirect to.
      # @param [Integer] code The HTTP code to use.
      # @example
      #     r = Renee.core { get { halt redirect '/index' } }
      #     r.call(Rack::MockResponse("/")) # => [302, {"Location" => "/index"}, []]
      def redirect(path, code = 302)
        response = ::Rack::Response.new
        response.redirect(path, code)
        response.finish
      end

      # Halts with a rack-based response for redirection.
      # @see #redirect
      # @param [String] path The URL to redirect to.
      # @param [Integer] code The HTTP code to use.
      # @example
      #     r = Renee.core { get { redirect! '/index' } }
      #     r.call(Rack::MockResponse("/")) # => [302, {"Location" => "/index"}, []]
      def redirect!(path, code = 302)
        halt redirect(path, code)
      end
    end
  end
end
