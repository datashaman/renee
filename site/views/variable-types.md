# Variable types

Renee makes it easy to add variable types and use them!

## Registering

To create a variable type, in your [setup block](/settings), add a #register_variable_type call. Example:

    :::ruby
    register_variable_type(:hex,       # The name
      /[0-9a-f]{6}/).                  # Part to capture
      on_transform { |v| v.to_i(16) }. # How to transform
      raise_on_error!                  # What to do when you can't
                                       #   capture

First, a registered type needs to have a name. Then, a regexp specifying what to match needs to be provided. If you want to transform the result, use `#on_transform` to pass a block to be called when this type is being used. If a type is attempted to be used, and the regexp doesn't manage to capture anything, the error handler is used to determine what to do. By default, there is no error handler, and so, your programs execution will continue normally. However, if you use`#on_error`, you can supply a block to be called in the event of an error. As a convenience, there is a `#raise_on_error!` method that will halt with a 400, or, if you choose, any HTTP error code you wish (which is an optional parameter to `#raise_on_error!`).

## Default types

By default, `:int` and `:integer` will ensure your variable is an `Integer`.

## Errors

The `#on_error` handler will accept a block. This block will then be executed in the context of your application. Feel free to `#render`, `#halt`, or do anything else you desire.

## Compound types

Types can also be composed from other defined types by supplying a list of other types. Here is an example:

    :::ruby
    regster_variable_type(:hex,    /0x[0-9a-f]+/).on_transform{|v| v.to_i(16)}
    regster_variable_type(:octal,  /0[0-7]+/)    .on_transform{|v| v.to_i(8)}
    regster_variable_type(:number, [:hex, :octal])

Now, `:number` will attempt to use the `:hex` matcher, then, the `:octal` matcher. Compound types can even have their own error matching.

## Aliasing types

As well, you can create as many type aliases as you want. Just do this:

    :::ruby
    regster_variable_type(:num, :int)

Now, you can refer to `:num` wherever you'd like.

## Using variable types outside of path variables

Sometimes, it would be nice to have access to the these variable types outside of the context of your path variables. If you wish, you can use `#transform` to recognize and transform an arbitrary `String`. Here is an example:

    :::ruby
    run Renee {
      get.halt "It turns out octal 0123 is #{transform(:octal, "0123")} in decimal."
    }.setup {
      register_variable_type(:octal, /0[0-7]+/).on_transform{|v| v.to_i(8)}
    }

You'll get `It turns out octal 0123 is 83 in decimal.` What fun!