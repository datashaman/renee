require 'renee/version'
require 'renee/core'
require 'renee/render'
require 'renee/session'
require 'renee/url_generation'

# Method for creating new Renee applications.
# @see http://reneerb.com
# @example
#     run Renee {
#       halt "hello renee"
#     }
def Renee(&blk)
  Class.new(Renee::Application).app(&blk)
end

# Top-level Renee constant.
module Renee
  # Main class for a Renee application. This class should be subclasses if you want to define your own Renee
  # implementations.
  class Application < Core
    include Render
    include URLGeneration
    include Session
  end
end
