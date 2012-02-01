# Extending Renee

Renee is a very modular library comprised of four standalone libraries:
`renee-core`, `renee-render`, `renee-url-generation`, and `renee-session`.

If you need additional functionality, extending Renee can be very easy and quick.
Renee extensions are basically just included modules. For example, let's say we wanted to implement a simple
extension. First, define the module:

    :::ruby
    module Renee
      module SampleExtension

        module ClassMethods
          # These are methods that live at the class level for Renee
        end

        def self.included(o)
          o.extend(ClassMethods)
          # ...more here...
        end

      end
    end

You can use hooks inside the `included` method to apply code at certain points in the renee lifecycle (init, before, after):

     :::ruby
     module Renee
       module SampleExtension
         def self.included(o)
           o.on_init do
             define_method(:foo) { 'bar' }
             # More things on initialize
           end

           o.on_before do
             # ...before every request...
           end

           o.on_after do
             # ...after every request...
           end
        end
      end
    end

And then subclass Renee to add your own libraries:

    :::ruby
    module Renee
      class MyApplication < Application
        include SampleExtension
      end
    end

You can now use your subclassed application with your libraries mixed in:

    :::ruby
    run Renee::MyApplication {
      path("/").get do
        halt! foo
      end
    }

and that's the basics for extending Renee. Checkout the renee source code and specifically `renee-sessions` for a more detailed example.