module Renee
  module Streaming
    AsyncResponse = [-1, {}, []]

    class Stream
      def self.schedule(*) yield end
      def self.defer(*)    yield end

      def initialize(scheduler = self.class, keep_open = false, &back)
        @back, @scheduler, @keep_open = back.to_proc, scheduler, keep_open
        @callbacks, @closed = [], false
      end

      def close
        return if @closed
        @closed = true
        @scheduler.schedule { @callbacks.each { |c| c.call }}
      end

      def each(&front)
        @front = front
        @scheduler.defer do
          begin
            @back.call(self)
          rescue Exception => e
            @scheduler.schedule { raise e }
          end
          close unless @keep_open
        end
      end

      def <<(data)
        @scheduler.schedule { @front.call(data.to_s) }
        self
      end

      def callback(&block)
        @callbacks << block
      end

      alias errback callback
    end

    def stream(keep_open = false, status = 200, headers = {'Content-Type' => 'text/html'}, &block)
      scheduler = env['async.callback'] ? EventMachine : Stream
      env['async.callback'].call [ status, headers, Stream.new(scheduler, keep_open, &block) ]
    end

    def stream!(*args, &block)
      stream(*args, &block)
      halt AsyncResponse
    end

    def close!(&block)
      env['async.close'].callback { block.call }
      halt AsyncResponse
    end
  end
end