$: << File.expand_path('../../lib', __FILE__)
require 'renee_bindings'
# Load shared test helpers
require File.expand_path('../../../lib/test_helper', __FILE__)

class MiniTest::Spec
  def assert_data_binding(bind, data)
    assert_equal data[:json], bind.from_ruby(data[:ruby]).as_json
    assert_equal data[:hash], bind.from_ruby(data[:ruby]).as_hash
    assert_equal data[:ruby], bind.from_json(data[:json]).as_ruby
    assert_equal data[:hash], bind.from_json(data[:json]).as_hash
    assert_equal data[:ruby], bind.from_hash(data[:hash]).as_ruby
    assert_equal data[:json], bind.from_hash(data[:hash]).as_json
  end
end
