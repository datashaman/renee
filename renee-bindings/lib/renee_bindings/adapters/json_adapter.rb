module Renee
  module Bindings
    module Adapters
      class JsonAdapter < PrimitiveAdapter
        def self.list(list)
          JsonListAdapter.new(list)
        end

        def self.object(attrs)
          JsonHashAdapter.new(attrs)
        end

        def self.create(obj)
          obj.is_a?(Array) ? JsonListAdapter.new(obj) : JsonHashAdapter.new(obj)
        end

        def self.decode(str)
          o = MultiJson.decode(str)
          o.is_a?(Array) ? JsonListAdapter.new(o) : JsonHashAdapter.new(o)
        end

        def self.from_file(f)
          decode(File.read(f))
        end

        def encode
          MultiJson.encode(obj)
        end

        class JsonHashAdapter < JsonAdapter
          include HashHelper

          def initialize(hash, opts = nil)
            # todo, assuming hashes have sym keys for now .. need to improve this.
            @obj = {}
            hash.each { |k,v| @obj[k.to_sym] = v }
          end
        end

        class JsonListAdapter < JsonAdapter
          include ArrayHelper
        end
      end
    end
  end
end
