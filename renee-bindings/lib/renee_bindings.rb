require 'multi_json'

require "renee_bindings/version"
require 'renee_bindings/adapters'
require 'renee_bindings/binding'
require 'renee_bindings/binding_factory'

module Renee
  module Bindings
    DefaultFactory = BindingFactory.new

    def self.method_missing(m, *args, &blk)
      DefaultFactory.respond_to?(m) ? DefaultFactory.send(m, *args, &blk) : super
    end

    DefaultFactory.add_adapter(:json, Bindings::Adapters::JSONAdapter)
    DefaultFactory.add_adapter(:ruby, Bindings::Adapters::RubyAdapter)
    DefaultFactory.add_adapter(:hash, Bindings::Adapters::PrimitiveAdapter)
  end
end
