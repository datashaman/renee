require File.expand_path('../test_helper', __FILE__)

describe "Route chaining" do

  it "should chaining" do
    type = { 'Content-Type' => 'text/plain' }
    mock_app do
      allow_continued_routing do
        path('/').get { halt [200,type,['foo']] }
        path('bar').put { halt [200,type,['bar']] }
        path('bar').var.put { |id| halt [200,type,[id]] }
        path('bar').var.get.halt { |id| "wow, nice to meet you " }
      end
    end
    get '/'
    assert_equal 200,   response.status
    assert_equal 'foo', response.body
    put '/bar'
    assert_equal 200,   response.status
    assert_equal 'bar', response.body
    put '/bar/asd'
    assert_equal 200,   response.status
    assert_equal 'asd', response.body
  end

  it "should chain and halt with a non-routing method" do
    type = { 'Content-Type' => 'text/plain' }
    mock_app do
      path('/').get.halt "hi"
    end
    get '/'
    assert_equal 200,   response.status
    assert_equal 'hi', response.body
  end
end