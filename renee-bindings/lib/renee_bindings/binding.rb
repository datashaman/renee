require 'set'

module Renee
  module Bindings
    class Binding
      attr_accessor :from, :to_class, :to

      def execute
        @rejected_params = Set.new
        @attrs = from.list? ? [] : {}
        instance_eval(&self.class._binding_blk)
        case @attrs
        when Hash
          @attrs.each {|k, v| @to.set_attr(k, v) }
        when Array
          @attrs.each_with_index {|v, i| @to.set_list_item(i, v) }
        end
        self
      end

      def reset!
        @to = nil
        @attrs.clear
        @rejected_params.clear
      end

      def reject(name)
        raise if @from.list?
        @rejected_params << name
      end

      def attr(name, opts = nil)
        binding = opts && opts[:binding]
        type = type && type[:type]
        if binding
          if type == :list
            list(name, binding, opts)
          else
            object(name, binding, opts)
            #raise # TODO support subobject mapping
          end
        else
          copy_attr(name, opts)
        end
      end

      def copy_attr(name, opts)
        @to ||= to_class.create_object
        from_val = @from.get_attr(name)
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
        @to ||= to_class.create_object
        bind = self.class._binding_factory.bindings[binding].new
        bind.to_class = to_class
        to_array = bind.to_class.create_list
        from_val = @from.get_list(name)
        from_val.get_list_size.times do |i|
          bind.to = nil
          bind.from = from_val.get_list_object(i)
          bind.execute
          to_array.set_list_item(i, bind.to.obj)
        end
        @attrs[name] = to_array.obj
      end

      def object(name, binding, opts = nil)
        @to ||= to_class.create_object
        bind = self.class._binding_factory.bindings[binding].new
        bind.to_class = to_class
        bind.to = to_object = bind.to_class.create_object
        bind.from = @from.get_object(name)
        bind.execute
        @attrs[name] = bind.to.obj
      end
    end
  end
end
