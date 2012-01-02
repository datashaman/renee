# Tutorial

This is the most basic ever tutorial, and admittedly, a lot of it is boilerplate setup. But hopefully, this demonstrates how easy it is to get up and running with Renee.

## Create a project and install your gems

    :::terminal
    $> mkdir renee-tutorial
    $> cd renee-tutorial
    $> bundle init
    Writing new Gemfile to /Users/joshbuddy/Gemfile/renee-tutorial
    $> mate .

Now in your editor, type:

    :::ruby
    source "http://rubygems.org"

    gem 'renee', '~> 0.3.0'
    gem 'shotgun'

Go back to your tutorial and install that dog!

    :::terminal
    $> bundle
    Installing bundler (1.0.21) 
    Installing callsite (0.0.6) 
    Installing rack (1.3.5) 
    Installing renee-core (0.2.0) 
    Installing tilt (1.3.3) 
    Installing renee-render (0.2.0) 
    Installing renee (0.2.0) 
    Installing shotgun (0.9) 
    Your bundle is complete! Use `bundle show [gemname]` to see where a bundled gem is installed.

## Write a hello world

In your editor, create the file `config.ru`. Now, edit that file.

    :::ruby
    require 'renee'
    
    run Renee {
      halt "hello world!"
    }

Back in your terminal, run:

    :::terminal
    $> bundle exec shotgun
    == Shotgun/WEBrick on http://127.0.0.1:9393/
    [2011-10-19 21:53:26] INFO  WEBrick 1.3.1
    [2011-10-19 21:53:26] INFO  ruby 1.8.7 (2011-06-30) [i686-darwin11.2.0]
    [2011-10-19 21:53:26] INFO  WEBrick::HTTPServer#start: pid=4312 port=9393

Now, point your browser to `http://localhost:9393/`! Enjoy!

