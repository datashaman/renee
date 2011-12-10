module Renee
  module Bindings
    module Adapters
      class PrimitiveAdapter < BaseAdapter
        def self.list(list)
          PrimitiveArrayAdapter.new(list)
        end

        def self.object(attrs)
          PrimitiveHashAdapter.new(attrs)
        end

        def self.create(obj)
          obj.is_a?(Array) ? PrimitiveArrayAdapter.new(obj) : PrimitiveHashAdapter.new(obj)
        end

        class PrimitiveHashAdapter < PrimitiveAdapter
          include HashHelper
          def initialize(hash, opts = nil)
            # todo, assuming hashes have sym keys for now .. need to improve this.
            @obj = {}
            hash.each { |k,v| @obj[k.to_sym] = v }
          end
        end

        class PrimitiveArrayAdapter < PrimitiveAdapter
          include ArrayHelper

          def initialize(list)
            @obj = list
          end
        end
      end
    end
  end
end
