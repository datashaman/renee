require File.expand_path('../test_helper', __FILE__)

describe Renee::JSON do
  describe "#render-json" do
    after  { remove_views }

    it "should render a JSON response" do
      input = { :key1 => 'value1', :key2 => 'value2' }
      mock_app {
        path("/echo") { get { json!(input) } }
      }
      get('/echo')
      assert_equal 200, response.status
      assert_equal 'application/json', response.headers['Content-Type']
      assert_equal JSON.dump(input), response.body
    end # render JSON response
  end
end
