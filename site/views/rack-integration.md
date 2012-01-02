# Rack integration

Renee loves Rack. To create a new Renee application, create a rackup file (typically `config.ru`) and load it using [shotgun](https://rubygems.org/gems/shotgun).

    :::ruby
    # config.ru
    run Renee do
      # ...
    end

From here, you can start consuming parts of the path. Consider:

    :::ruby
    # config.ru
    run Renee do
      puts env['SCRIPT_NAME'] # /
      puts env['PATH_INFO'] # /blog/something
      path 'blog' do
        puts env['SCRIPT_NAME'] # /blog
        puts env['PATH_INFO'] # /something
        # .. 
      end
    end

The path is being shifted from PATH_INFO and onto the SCRIPT_NAME. This makes it easy to stop what you're doing, and call into a Rack application, as your `env` will be in the correct state for dispatching to another Rack application. To dispatch at any point you can use `#run!`. Example:

    :::ruby
    # config.ru
    OtherApp = proc { |env| [200, {}, [env['SCRIPT_NAME'], env['PATH_INFO']]]}

    run Renee do
      path 'blog' do
        run! OtherApp
      end
    end

Now, any request starting with `/blog` will be dispatched to `OtherApp`.

If you'd like to use a full Rack::Builder, you can use `#build!`.

    :::ruby
    run Renee do
      path 'blog' do
        build! do
          use SomeMiddleware
          run SomeRackApplication
        end
      end
    end
    
Full documentation can be found under the YARD docs for  [`Renee::Core::Application::RackIntegration`](http://reneerb.com/doc/core/Renee/Core/Application/RackInteraction.html).