$: << File.expand_path('../../../renee/core/lib', __FILE__)
$: << File.expand_path('../../lib', __FILE__)
require 'renee/core'
require 'renee/session'

Renee::Core.send(:include, Renee::Session)

# Load shared test helpers
require File.expand_path('../../test_helper', __FILE__)
