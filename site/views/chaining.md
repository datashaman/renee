# Chaining

Renee makes it easy to chain together any of the [routing](/routing) methods. Take this example:

    :::ruby
    run Renee {
      path 'test' do
        get do
          halt "hi"
        end
      end
    }

This is nice, but, it could be nicer. With chaining, any method that takes a block can simply be chained to the next one. We could re-write this in the following way.

    :::ruby
    run Renee { path('test').get.halt "hi" }

## Passing around chaining contexts

Chains you build up are re-usable as well. In the above example, if we wanted we could save that chaining context and re-use it as many times as we wanted. Here is an example:

    :::ruby
    run Renee {
      test_path = path('test')
      test_path.get.halt "this is a get"
      test_path.post.halt "this is a post"
    }

## Implementing chains for your own modules

If you wish to use chaining yourself in your own modules, simple include Application::Chaining. Then, mark chainable methods with `chain_method :method_name`.
