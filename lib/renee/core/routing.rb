module Renee
  class Core
    # Collection of useful methods for routing within a {Renee::Core} app.
    module Routing
      include Chaining

      # Allow continued routing if a routing block fails to match
      # 
      # @param [Boolean] val
      #   indicate if continued routing should be allowed.
      #
      # @api public
      def continue_routing
        if block_given?
          original_env = @env.dup
          begin
            yield
          rescue NotMatchedError
            @env = original_env
          end
        else
          create_chain_proxy(:continue_routing)
        end
      end
      chainable :continue_routing

      # Match a path to respond to.
      #
      # @param [String] p
      #   path to match.
      # @param [Proc] blk
      #   block to yield
      #
      # @example
      #   path('/')    { ... } #=> '/'
      #   path('test') { ... } #=> '/test'
      #
      #   path 'foo' do
      #     path('bar') { ... } #=> '/foo/bar'
      #   end
      #
      # @api public
      def path(p, &blk)
        if blk
          p = p[1, p.size] if p[0] == ?/
          extension_part = detected_extension ? "|\\.#{Regexp.quote(detected_extension)}" : ""
          part(/^\/#{Regexp.quote(p)}(?=\/|$#{extension_part})/, &blk)
        else
          create_chain_proxy(:path, p)
        end
      end
      chainable :path

      # Like #path, but doesn't look for leading slashes.
      def part(p)
        if block_given?
          p = /^\/?#{Regexp.quote(p)}/ if p.is_a?(String)
          if match = env['PATH_INFO'][p]
            with_path_part(match) { yield }
          end
        else
          create_chain_proxy(:part, p)
        end
      end

      # Match parts off the path as variables. The parts matcher can conform to either a regular expression, or be an Integer, or
      # simply a String.
      # @param[Object] type the type of object to match for. If you supply Integer, this will only match integers in addition to casting your variable for you.
      # @param[Object] default the default value to use if your param cannot be successfully matched.
      #
      # @example
      #   path '/' do
      #     variable { |id| halt [200, {}, id] }
      #   end
      #   GET /hey  #=> [200, {}, 'hey']
      #
      # @example
      #   path '/' do
      #     variable(:integer) { |id| halt [200, {}, "This is a numeric id: #{id}"] }
      #   end
      #   GET /123  #=> [200, {}, 'This is a numeric id: 123']
      #
      # @example
      #   path '/test' do
      #     variable { |foo, bar| halt [200, {}, "#{foo}-#{bar}"] }
      #   end
      #   GET /test/hey/there  #=> [200, {}, 'hey-there']
      #
      # @api public
      def variable(*types, &blk)
        blk ? complex_variable(types, '/', types.empty? ? 1 : types.size , &blk) : create_chain_proxy(:variable, *types)
      end
      alias_method :var, :variable
      chainable :variable, :var

      def optional_variable(type = nil, &blk)
        blk ? complex_variable(type, '/', 0..1) { |vars| blk[vars.first] } : create_chain_proxy(:variable, type)
      end
      alias_method :optional, :optional_variable
      chainable :optional, :optional_variable

      # Same as variable except you can match multiple variables with the same type.
      # @param [Range, Integer] count The number of parameters to capture.
      # @param [Symbol] type The type to use for match.
      def multi_variable(count, type = nil, &blk)
        blk ? complex_variable(type, '/', count, &blk) : create_chain_proxy(:multi_variable, count, type)
      end
      alias_method :multi_var, :multi_variable
      alias_method :mvar, :multi_variable
      chainable :multi_variable, :multi_var, :mvar

      # Same as variable except it matches indefinitely.
      # @param [Symbol] type The type to use for match.
      def repeating_variable(type = nil, &blk)
        blk ? complex_variable(type, '/', nil, &blk) : create_chain_proxy(:repeating_variable, type)
      end
      alias_method :glob, :repeating_variable
      chainable :repeating_variable, :glob

      # Match parts off the path as variables without a leading slash.
      # @see #variable
      # @api public
      def partial_variable(type = nil, &blk)
        blk ? complex_variable(type, nil, 1, &blk) : create_chain_proxy(:partial_variable, type)
      end
      alias_method :part_var, :partial_variable
      chainable :partial_variable, :part_var

      # Returns the matched extension. If no extension is present, returns `nil`.
      #
      # @example
      #   halt [200, {}, path] if extension == 'html'
      #
      # @api public
      def extension
        detected_extension
      end
      alias_method :ext, :extension

      # Match no extension.
      #
      # @example
      #   no_extension { |path| halt [200, {}, path] }
      #
      # @api public
      def no_extension(&blk)
        blk.call unless detected_extension
      end

      # Match any remaining path.
      #
      # @example
      #   remainder { |path| halt [200, {}, path] }
      #
      # @api public
      def remainder(&blk)
        blk ? with_path_part(env['PATH_INFO']) { |var| blk.call(var) } : create_chain_proxy(:remainder)
      end
      alias_method :catchall, :remainder
      chainable :remainder, :catchall

      # Respond to a GET request and yield the block.
      #
      # @example
      #   get { halt [200, {}, "hello world"] }
      #
      # @api public
      def get(&blk)
        blk ? request_method('GET', &blk) : create_chain_proxy(:get)
      end
      chainable :get

      # Respond to a POST request and yield the block.
      #
      # @example
      #   post { halt [200, {}, "hello world"] }
      #
      # @api public
      def post(&blk)
        blk ? request_method('POST', &blk) : create_chain_proxy(:post)
      end
      chainable :post

      # Respond to a PUT request and yield the block.
      #
      # @example
      #   put { halt [200, {}, "hello world"] }
      #
      # @api public
      def put(&blk)
        blk ? request_method('PUT', &blk) : create_chain_proxy(:put)
      end
      chainable :put

      # Respond to a DELETE request and yield the block.
      #
      # @example
      #   delete { halt [200, {}, "hello world"] }
      #
      # @api public
      def delete(&blk)
        blk ? request_method('DELETE', &blk) : create_chain_proxy(:delete)
      end
      chainable :delete

      # Match only when the path is either '' or '/'.
      #
      # @example
      #   complete { halt [200, {}, "hello world"] }
      #
      # @api public
      def complete(&blk)
        if blk
          with_path_part(env['PATH_INFO']) { blk.call } if complete?
        else
          create_chain_proxy(:complete)
        end
      end
      chainable :complete

      # Test if the path has been consumed
      #
      # @example
      #   if complete?
      #     halt "Hey, the path is done"
      #   end
      #
      # @api public
      def complete?
        (detected_extension and env['PATH_INFO'] =~ /^\/?(\.#{Regexp.quote(detected_extension)}\/?)?$/) || (detected_extension.nil? and env['PATH_INFO'] =~ /^\/?$/)
      end

      # Match only when the path is ''.
      #
      # @example
      #   empty { halt [200, {}, "hello world"] }
      #
      # @api public
      def empty(&blk)
        if blk
          if env['PATH_INFO'] == ''
            with_path_part(env['PATH_INFO']) { blk.call }
          end
        else
          create_chain_proxy(:empty)
        end
      end
      chainable :empty

      private
      def complex_variable(type, prefix, count)
        path = env['PATH_INFO'].dup
        vals = []
        variable_matching_loop(count) do |idx|
          matcher = variable_matcher_for_type(type.respond_to?(:at) ? type.at(idx) : type)
          path.start_with?(prefix) ? path.slice!(0, prefix.size) : break if prefix
          if match = matcher[path]
            path.slice!(0, match.first.size)
            vals << match.last
          end
        end
        return unless count.nil? || count === vals.size
        with_path_part(env['PATH_INFO'][0, env['PATH_INFO'].size - path.size]) do
          if count == 1
            yield(vals.first)
          else
            yield(vals)
          end
        end
      end

      def variable_matching_loop(count)
        case count
        when Range then count.max.times { |i| break unless yield i }
        when nil   then i = 0; loop { break unless yield i; i+= 1 }
        else            count.times { |i| break unless yield i }
        end
      end

      def variable_matcher_for_type(type)
        if self.class.variable_types.key?(type)
          self.class.variable_types[type]
        else
          regexp = case type
          when nil, String
            detected_extension ?
              /(([^\/](?!#{Regexp.quote(detected_extension)}$))+)(?=$|\/|\.#{Regexp.quote(detected_extension)})/ :
              /([^\/]+)(?=$|\/)/
          when Regexp
            type
          else
            raise "Unexpected variable type #{type.inspect}"
          end
          proc do |path|
            if match = /^#{regexp.to_s}/.match(path)
              [match[0]]
            end
          end
        end
      end

      def with_path_part(part)
        script_part = env['PATH_INFO'][0, part.size]
        env['PATH_INFO'] = env['PATH_INFO'].slice(part.size, env['PATH_INFO'].size)
        env['SCRIPT_NAME'] += script_part
        yield script_part
        raise NotMatchedError
      end

      def request_method(method)
        if env['REQUEST_METHOD'] == method && complete?
          yield
          raise NotMatchedError
        end
      end
    end
  end
end
