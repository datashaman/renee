require 'renee/util'
require 'renee/version'

module Renee
  module Session
    module ClassMethods
      attr_reader :store_type

      def add_session_type(type, cls)
        session_stores[type] = cls
      end

      def session(type, *args, &blk)
        if session_stores.key?(type)
          @store_type = [session_stores[type], args, blk]
        else
          raise "Store type #{type} is unknown, choose from #{session_stores.keys.map(&:inspect).join(', ')}"
        end
      end

      def disable_session
        @store_type = nil
      end

      def session_enabled?
        !@store_type.nil?
      end

      def session_stores
        @session_stores ||= {}
      end
    end

    def self.included(o)
      o.extend(ClassMethods)
      o.add_session_type :cookie, 'Rack::Session::Cookie'
      o.add_session_type :pool, 'Rack::Session::Pool'
      o.add_session_type :memcache, 'Rack::Session::Memcache'
      o.on_init do
        session_constant = Renee::Util.lookup_constant(store_type[0])
        use session_constant, *store_type[1], &store_type[2]
        define_method(:session) { env[Rack::Session::Abstract::ENV_SESSION_KEY] }
      end
    end

    def session
      raise "Session not enabled"
    end
  end
end
