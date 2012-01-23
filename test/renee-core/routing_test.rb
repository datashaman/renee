require File.expand_path('../test_helper', __FILE__)

describe Renee::Core::Routing do

  def renee_for(path, options = {}, &block)
    Renee.core(&block).call(Rack::MockRequest.env_for(path, options))
  end

  describe "with paths" do
    it "generates a basic route" do
      type = { 'Content-Type' => 'text/plain' }
      mock_app do
        path('/')   { get { halt [200,type,['foo']] } }
        path('bar') { put { halt [200,type,['bar']] } }

        path '/foo' do
          delete { halt [200,type,['hi']] }

          path '/bar/har' do
            get  { halt [200,type,['foobar']] }
            post { halt [200,type,['posted']] }
          end

        end
      end
      get '/'
      assert_equal 200,   response.status
      assert_equal 'foo', response.body
      put '/bar'
      assert_equal 200,   response.status
      assert_equal 'bar', response.body
      delete '/foo'
      assert_equal 200,   response.status
      assert_equal 'hi', response.body
      get '/foo/bar/har'
      assert_equal 200,   response.status
      assert_equal 'foobar', response.body
      post '/foo/bar/har'
      assert_equal 200,   response.status
      assert_equal 'posted', response.body
    end

    describe "with trailing slashes" do
      it "should ignore trailing slashes normally" do
        type = { 'Content-Type' => 'text/plain' }
        mock_app do
          path('test') { get { halt [200,type,['test']] } }
        end

        get '/test/'
        assert_equal 200,    response.status
        assert_equal 'test', response.body
        get '/test'
        assert_equal 200,    response.status
        assert_equal 'test', response.body
      end

      it "should not ignore trailing slashes if told not to" do
        type = { 'Content-Type' => 'text/plain' }
        mock_app do
          path('test').empty { get { halt [200,type,['test']] } }
        end
        get '/test/'
        assert_equal 404,    response.status
        get '/test'
        assert_equal 200,    response.status
        assert_equal 'test', response.body
      end
    end
  end

  describe "with variables" do

    it "generates for path" do
      type = { 'Content-Type' => 'text/plain' }
      mock_app do
        path 'test' do
          variable do  |id|
            get { halt [200,type,[id]] }
          end
        end

        path 'two' do
          var.var do |foo, bar|
            get { halt [200, type,["#{foo}-#{bar}"]] }
          end
        end

        path 'multi' do
          multi_var(3) do |foo, bar, lol|
            post { halt [200, type,["#{foo}-#{bar}-#{lol}"]] }
          end
        end
      end

      get '/test/hello'
      assert_equal 200,     response.status
      assert_equal 'hello', response.body
      get '/two/1/2'
      assert_equal 200,     response.status
      assert_equal '1-2',   response.body
      post '/multi/1/2/3'
      assert_equal 200,     response.status
      assert_equal '1-2-3', response.body
    end

    it "generates nested paths" do
      type = { 'Content-Type' => 'text/plain' }
      mock_app do
        path 'test' do
          var do |id|
            path 'moar' do
              post { halt [200, type, [id]] }
            end

            path 'more' do
              var.var do |foo, bar|
                get { halt [200, type, ["#{foo}-#{bar}"]] }

                path 'woo' do
                  get { halt [200, type, ["#{foo}-#{bar}-woo"]] }
                end
              end
            end
          end
        end
      end

      post '/test/world/moar'
      assert_equal 200,       response.status
      assert_equal 'world',   response.body
      get '/test/world/more/1/2'
      assert_equal 200,       response.status
      assert_equal '1-2',     response.body
      get '/test/world/more/1/2/woo'
      assert_equal 200,       response.status
      assert_equal '1-2-woo', response.body
    end

    it "accepts an typcasts integers" do
      type = { 'Content-Type' => 'text/plain' }
      mock_app do
        path 'add' do
          var(:integer).var(:integer) do |a, b|
            halt [200, type, ["#{a + b}"]]
          end
        end
      end

      get '/add/3/4'
      assert_equal 200, response.status
      assert_equal '7', response.body
    end

    it "can take an optional variable" do
      type = { 'Content-Type' => 'text/plain' }
      mock_app do
        path 'add' do
          var(:integer).optional(:integer) do |a, b|
            b ||= a
            halt [200, type, ["#{a + b}"]]
          end
        end
      end

      get '/add/3/4'
      assert_equal 200, response.status
      assert_equal '7', response.body
      get '/add/3'
      assert_equal 200, response.status
      assert_equal '6', response.body
    end

    it "allows arbitrary ranges of values" do
      type = { 'Content-Type' => 'text/plain' }
      mock_app do
        path 'add' do
          multi_var(2..5, :integer).get do |numbers|
            halt [200, type, ["Add up to #{numbers.inject(numbers.shift) {|m, i| m += i}}"]]
          end
        end
      end

      get '/add/3/4'
      assert_equal 200, response.status
      assert_equal 'Add up to 7', response.body
      get '/add/3/4/6/7'
      assert_equal 200, response.status
      assert_equal 'Add up to 20', response.body
      get '/add/3/4/6/7/8/10/2'
      assert_equal 404, response.status
    end

    it "accepts allows repeating vars" do
      type = { 'Content-Type' => 'text/plain' }
      mock_app do
        path 'add' do
          glob :integer do |numbers|
            halt [200, type, ["Add up to #{numbers.inject(numbers.shift) {|m, i| m += i}}"]]
          end
        end
      end

      get '/add/3/4'
      assert_equal 200, response.status
      assert_equal 'Add up to 7', response.body
      get '/add/3/4/6/7'
      assert_equal 200, response.status
      assert_equal 'Add up to 20', response.body
    end

    it "accepts a regexp" do
      type = { 'Content-Type' => 'text/plain' }
      mock_app do
        path 'add' do
          var(/foo|bar/).var(/foo|bar/) do |a, b|
            halt [200, type, ["#{a + b}"]]
          end
        end
      end

      get '/add/bar/foo'
      assert_equal 200,      response.status
      assert_equal 'barfoo', response.body
    end
  end

  describe "with remainder" do

    it "matches the rest of the routes" do
      type = { 'Content-Type' => 'text/plain' }
      mock_app do
        path 'test' do
          get { halt [200,type,['test']] }

          remainder do |rest|
            post { halt [200, type, ["test-#{rest}"]] }
          end
        end

        remainder do |rest|
          halt [200, type, [rest]]
        end
      end

      get '/a/b/c'
      assert_equal 200,      response.status
      assert_equal '/a/b/c', response.body
      post '/test/world/moar'
      assert_equal 200,      response.status
      assert_equal 'test-/world/moar', response.body
    end
  end

  describe "with extensions" do
    it "should match an extension" do
      type = { 'Content-Type' => 'text/plain' }
      mock_app do
        path('/test').get do
          case extension
          when 'html' then halt [200, type, ['test html']]
          when 'json' then halt [200, type, ['test json']]
          when nil    then halt [200, type, ['test nope']]
          else             halt [406, type, ['unknown']]
          end
        end
        
        extension 'html' do
          halt [200, type, ['test html']]
        end
      end
      get '/test.html'
      assert_equal 200,    response.status
      assert_equal 'test html', response.body
      get '/test.json'
      assert_equal 200,    response.status
      assert_equal 'test json', response.body
      get '/test.xml'
      assert_equal 406,    response.status
    end

    it "should match an extension when there is a non-specific variable before" do
      mock_app do
        var do |id|
          case extension
          when 'html' then halt "html #{id}"
          when 'xml'  then halt "xml #{id}"
          when nil    then halt "none #{id}"
          end
        end
      end
      get '/var.html'
      assert_equal 200,        response.status
      assert_equal 'html var', response.body
      get '/var.xml'
      assert_equal 200,        response.status
      assert_equal 'xml var',  response.body
      get '/var'
      assert_equal 200,        response.status
      assert_equal 'none var',  response.body
    end
  end

  describe "with part and part_var" do
    it "should match a part" do
      mock_app do
        part '/test' do
          part 'more' do
            halt :ok
          end
        end
      end
      get '/testmore'
      assert_equal 200,    response.status
    end

    it "should match a part_var" do
      mock_app do
        part '/test' do
          part 'more' do
            part_var do |var|
              path 'test' do
                halt var
              end
            end
          end
        end
      end
      get '/testmorethisvar/test'
      assert_equal 'thisvar',    response.body
    end

    it "should match a part_var with Integer" do
      mock_app do
        part '/test' do
          part 'more' do
            part_var :integer do |var|
              path 'test' do
                halt var.to_s
              end
            end
          end
        end
      end
      get '/testmore123/test'
      assert_equal '123',    response.body
      get '/testmore123a/test'
      assert_equal 404,    response.status
    end
  end

  describe "multiple Renee's" do
    it "should pass between them normally" do
      type = { 'Content-Type' => 'text/plain' }
      mock_app do
        path 'test' do
          halt run Renee.core {
            path 'time' do
              halt halt [200,type,['test']]
            end
          }
        end
      end
      get '/test/time'
      assert_equal 200,    response.status
      assert_equal 'test', response.body
    end

    it "should support run! passing between" do
      type = { 'Content-Type' => 'text/plain' }
      mock_app do
        path 'test' do
          run! Renee.core {
            path 'time' do
              halt halt [200,type,['test']]
            end
          }
        end
      end
      get '/test/time'
      assert_equal 200,    response.status
      assert_equal 'test', response.body
    end
  end

  describe "#build" do
    it "should allow building in-place rack apps" do
      type = { 'Content-Type' => 'text/plain' }
      mock_app do
        path('test') do
          halt build {
            run proc {|env| [200, type, ['someone built me!']] }
          }
        end
      end

      get '/test'
      assert_equal 200,                 response.status
      assert_equal 'someone built me!', response.body
    end
  end

  describe "#part and #part_var" do
    it "should match parts and partial vars" do
      mock_app do
        part('test') {
          part_var(:integer) { |id|
            part('more') {
              halt "the id is #{id}"
            }
          }
        }
      end
      get '/test123more'
      assert_equal 200,                 response.status
      assert_equal 'the id is 123',     response.body
    end
  end

  describe "request methods" do
    it "should allow request method routing when you're matching on /" do
      type = { 'Content-Type' => 'text/plain' }
      mock_app do
        get { halt [200, type, ["hiya"]] }
      end

      get '/'
      assert_equal 200,    response.status
      assert_equal 'hiya', response.body
    end

    it "should raise if you fail to halt" do
      type = { 'Content-Type' => 'text/plain' }
      mock_app do
        get {  }
        halt :ok
      end

      get '/'
      assert_equal 404,    response.status
    end
  end
end
