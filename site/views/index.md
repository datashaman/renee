# Welcome to Renee!

*Renee is the super-friendly Rack based web framework.*

    :::ruby
    run Renee {
      path('/') { halt "Hello Renee!" }
    }

This site was built using Renee and is [available on Github](https://github.com/renee-project/renee/site).

Want the 2 minute intro? Try out this deadly simple [tutorial](/tutorial).

## Concept (Why Renee?)

**Renee is a new way to think about writing web applications.**

### Hierarchical

Traditionally, routing and controller logic have been separate. In Rails, for instance, your path is matched to a controller and an action. This does not reflect the hierarchical nature of REST.

Consider a simple example. The route `/posts/45/comments`. Typically, you'd expect this to load the post with the id 45, and then load the comments on that post. In [Rails](http://rubyonrails.org/), your code to load a post and understand that parameter would have to be in both your posts controller and your comments controller. [Sinatra](http://www.sinatrarb.com/) does no better as it searches linearly though a list of path to find a matching path, and then executes the block associated with it.

To model this same idea in Renee, you could do the following:

    :::ruby
    run Renee do
      path 'posts' do
        var :int do |id|
          post = Posts.find(id)
          path 'comments' do
            get { render! "comments", :comments => post.comments }
          end
        end
      end
    end

Suddenly, you have access to the previously referred to part of the path, namely, the `/posts/45` part. It's a locally scoped variable, as is the id, so you don't have to worry about anyone outside of it's scope having access to it.

To find out more, take a look at the [routing methods](/routing) available to you.

### Composability

Renee lives and breathes inside of [Rack](http://rack.rubyforge.org/). Let's take a look at the example above and understand a little better what's going on. We'll modify it slightly for the sake of clarity:

    :::ruby
    run Renee do
      p request.path_info     # printing
      path "posts" do
        p request.path_info   # printing
        var :int do |id|
          p request.path_info # printing
          halt :ok
        end
      end
    end

If you run a request with the path `/posts/12` through here, you'll get three print statements:

    :::ruby
    "/posts/123"
    "/123"
    ""

The PATH_INFO is being consumed by each scope. If you don't halt, don't worry, your request will get put back together again after it falls out of each block. This let's you move parts of your application around without fearing how the route is being consumed.

### Rack integration

Renee loves Rack. To run a arbitrary rack end point, you can use `#run!` to stop execution and pass off your request to an Rack application. An example:

    :::ruby
    run Renee do
      path "posts" do
        run! PostsEndpoint # this can be any Rack application
      end
    end

To find out more about integrating with rack, take a look at [rack integration](/rack-integration) to find out more!

### Type validation

Converting your variable and returning 400's or 404's can get tedious, so why not do it all in one place? Renee allows you to register
arbitrary variable types, transform them, and handle error cases in one, easy place. Here is an example!

    :::ruby
    run Renee {
      path "color" do
        var :hex do |color|
          get { halt "<body bgcolor='##{color.to_s(16)}'></body>" }
        end
      end
    }.setup {
      register_variable_type(:hex, /[0-9a-f]{6}/).
        on_transform { |v| v.to_i(16) }.
        halt_on_error!
    }

Now, let's throw some requests against this. If we go to `http://127.0.0.1:9393/color/ff99ff`, we'll get a nice fuchsia. Try `http://127.0.0.1:9393/color/blue` and you'll get a 400. Too bad.

To find out more about [variable types](/variable-types), read all about them!

### Chaining

Okay, so, writing blocks is fun, but, it can get a bit indent-y when we don't really need it to be. Feel free to chain together whatever methods you'd like. For instance the above example could have been written:

    :::ruby
    run Renee {
      path("color").var(:hex).get { |color| halt "<body bgcolor='##{color.to_s(16)}'></body>" }
    }.setup {
      register_variable_type(:hex, /[0-9a-f]{6}/).
        on_transform { |v| v.to_i(16) }.
        halt_on_error!
    }

You can easily consume chaining yourself, if you want to implement your own routing methods. Find out [more](/chaining)!

### Subclassing for great justice

Not happy with what Renee gives you? You can easily subclass to define whatever you need.

    :::ruby
    class MyApp < Renee::Application
      run {
        path('justice/great').get.for_great_justice!
        halt 404, "justice not found"
      }

      def for_great_justice!
        halt "for great justice!"
      end
    end

    run MyApp

    # curl http://localhost:9393/justice/great
    # for great justice
    # curl http://localhost:9393/justice/good
    # justice not found


## Getting started

### Installation

Renee is gem-based. If you're using rubygems, you can simply:

    $> gem install renee

If you're using [Bundler](http://gembundler.com/), you can add

    :::ruby
    gem 'renee', '~> 0.3.0'

to your `Gemfile`.

### Overview

Renee has (hopefully) a small number of keywords divided between several components:

* *Routing* is done either on the path, the query string, or other parts of the request headers.
* *Responding* makes it easy to respond to a request.
* *Rendering* gives you access to [Tilt](https://github.com/rtomayko/tilt) for rendering templates.
* *Rack interaction* makes it easy to call into [Rack](http://rack.rubyforge.org/)-based applications.
* *Request context* gives you access to the request and gives the basis for responding.

## Usage

Using Renee is as simple as understanding how to *configure settings*, *define routes*, and *respond to requests*.
Renee usage in a nutshell:

    :::ruby
    run Renee {
      path 'blog' do
        get  { render! "posts/index" }
        post { Blog.create(request.params); halt :created }
        var do |id|
          @blog = Blog.get(id)
          get { render! "posts/show" }
          put { @blog.update(request.params); halt :ok }
        end
      end
    }.setup {
      views_path "./views"
    }

Check out detailed guides for each aspect below:

[&#8618; Read about Configuration](/settings)

[&#8618; Read about Responding and Rendering](/responding)

[&#8618; Read about Routing](/routing)

[&#8618; Read about Route generation](/route-generation)


## Extending Renee

Renee is a very modular library comprised of four standalone libraries:
`renee-core`, `renee-render`, `renee-url-generation`, and `renee-session`.

If you need additional functionality, extending Renee can be very easy and quick.
Renee extensions are basically just included modules. Check out the [Extending Renee](/extending)
guide for more information.

## API documentation

Renee is also well-documented with YARD:

[&#8618; renee](/docs/renee/index.html)

[&#8618; renee-core](/docs/renee-core/index.html)

[&#8618; renee-render](/docs/renee-render/index.html)

[&#8618; renee-url-generation](/docs/renee-url-generation/index.html)

[&#8618; renee-session](/docs/renee-session/index.html)

## Development

Renee's structure is pretty simple so far. The basic Rack DSL is contained in
[renee-core](https://github.com/renee-project/renee/tree/master/renee-core). This gem has no other dependencies other than Rack.

The rendering side is in [renee-render](https://github.com/renee-project/renee/tree/master/renee-render),
which depends on [Tilt](https://github.com/rtomayko/tilt).

The kitchen-sink gem which incorporates all of the others is [renee](https://github.com/renee-project/renee/tree/master/renee).
Please, any bugs, any ideas, I'd love to hear any of it. Love, [Team Renee](/team-renee). &hearts;
