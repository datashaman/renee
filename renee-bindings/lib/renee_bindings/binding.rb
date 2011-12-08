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
        raise if @from.list?
        @to ||= to_class.create_object
        valid = true
        val = from.get_attr(name)
        validator = opts && opts[:validate]
        case validator
        when Proc
          begin
            val = validator[val]
          rescue
            valid = false
          end
        when :int, :integer
          begin
            val = Integer(val)
          rescue
            valid = false
          end
        end
        @attrs[name] = val if valid
      end

      def list(name, binding, &blk)
        raise if @from.list?
        @to ||= to_class.create_object
        bind = self.class._binding_factory.bindings[binding].new
        from_array = @from.get_attr(name)
        bind.to_class = to_class
        to_array = bind.to_class.create_list
        from_array.get_list_size.times do |i|
          bind.to = nil
          bind.from = from_array.get_list_item(i)
          bind.execute
          to_array.set_list_item(i, bind.to.obj)
        end
        @attrs[name] = to_array.obj
      end
    end
  end
end
