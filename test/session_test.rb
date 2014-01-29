require File.expand_path('../test_helper', __FILE__)

describe Renee::Session do
  before do
    @app = Class.new(Renee::Core) do
      include Renee::Session

      # Add a secret to stop the complaining
      session :cookie, :secret => 'testing'
    end
  end

  it "should create a session" do
    @app.run do
      session[:test] = 'hello'
      path('test').get.halt "why #{session[:test]}"
    end
    get '/test'
    assert_equal "why hello", response.body
  end

  it "should persist values across multiple calls" do
    @app.run do
      out = session[:test] || "first"
      session[:test] = 'hello'
      path('test').get.halt out
    end
    get '/test'
    assert_equal "first", response.body
    get '/test'
    assert_equal "hello", response.body
  end
end
