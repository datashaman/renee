require File.expand_path('../test_helper', __FILE__)

describe Renee::Session do
  before do
    @app = Class.new(Renee::Core) do
      include Renee::Session
      session :cookie
    end
  end

  it "should create a session" do
    @app.app do
      session[:test] = 'hello'
      path('test').get.halt "why #{session[:test]}"
    end
    get '/test'
    assert_equal "why hello", response.body
  end
end
