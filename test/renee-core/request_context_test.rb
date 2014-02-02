require_relative '../test_helper'

class AddHelloThereMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    if env['hello']
      env['hello'] << "there"
    else
      env['hello'] = 'hello'
    end
    @app.call(env)
  end
end

class AddWhatsThatMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    if env['hello']
      env['hello'] << "that"
    else
      env['hello'] = 'whats'
    end
    @app.call(env)
  end
end

describe "Route::Core::RequestContext#use" do
  it "should allow the inclusion of arbitrary middlewares" do
    type = { 'Content-Type' => 'text/plain' }
    @app = Renee.core {
      halt env['hello']
    }.setup {
      use AddHelloThereMiddleware
    }
    get '/'
    assert_equal 200,     response.status
    assert_equal 'hello', response.body
  end

  it "should call middlewares in sequence (1)" do
    type = { 'Content-Type' => 'text/plain' }
    @app = Renee.core {
      halt env['hello']
    }.setup {
      use AddHelloThereMiddleware
      use AddWhatsThatMiddleware
    }
    get '/'
    assert_equal 200,     response.status
    assert_equal 'hellothat', response.body
  end

  it "should call middlewares in sequence (2)" do
    @app = Renee.core {
      halt env['hello']
    }.setup {
      use AddWhatsThatMiddleware
      use AddHelloThereMiddleware
    }
    get '/'
    assert_equal 200,     response.status
    assert_equal 'whatsthere', response.body
  end
end
