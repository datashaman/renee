module Renee
  module Bindings
    module Binding
      class ObjectBinding < BaseBinding
        def attr(name, opts = nil)
          binding = opts && opts[:binding]
          type = type && type[:type]
          if binding
            if type == :list
              list(name, binding, opts)
            else
              object(name, binding, opts)
            end
          else
            copy_attr(name, opts)
          end
        end

        def copy_attr(name, opts)
          from_val = @from.get(name)
          valid = true
          validator = opts && opts[:validate]
          case validator
          when Proc
            begin
              val = validator[from_val]
            rescue
              valid = false
            end
          when :int, :integer
            begin
              val = Integer(from_val)
            rescue
              valid = false
            end
          else
            val = from_val
          end
          @attrs[name] = val if valid
        end

        def list(name, binding, opts = nil)
          bind = @factory.bind_list(binding)
          bind.to_class = @to_class
          to_array = []
          from_val = @from.get_list(name)
          from_val.size.times do |i|
            bind.to = nil
            bind.from = from_val.get_object(i)
            bind.execute
            to_array << bind.to.obj
          end
          @attrs[name] = bind.to_class.list(to_array).obj
        end

        def object(name, binding, opts = nil)
          bind = @factory.bind_object(binding)
          bind.to_class = to_class
          bind.from = @from.get_object(name)
          bind.execute
          @attrs[name] = bind.to.obj
        end

        def int(name, opts = nil)
          @attrs[name] = @from.get_int(name)
        end

        def float(name, opts = nil)
          @attrs[name] = @from.get_float(name)
        end

        def execute
          @attrs = {}
          instance_eval(&@data.block)
          @to = to_class.object(@attrs, &@data.generator)
          self
        end
      end
    end
  end
end
