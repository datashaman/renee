$: << File.expand_path('../../lib', __FILE__)
require 'renee/url_generation'
# Load shared test helpers
require File.expand_path('../../test_helper', __FILE__)

class MiniTest::Spec
  def generator
    @generator ||= Renee::URLGeneration::GeneratorSet.new
  end
end