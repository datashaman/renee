require 'set'

module Renee
  module Bindings
    class Binding
      attr_accessor :to_class, :to, :validate_type, :from

      def initialize(factory, &blk)
        @factory, @blk = factory, blk
      end

      def execute
        @rejected_params = Set.new
        @from.list? ? execute_list : execute_object
        self
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

      #def decode_method(m)
      #  split_m = m.to_s.split(/_/, 2)
      #  case split_m.first
      #  when 'from'
      #    if m = split_m.last.match(/^(.*?)_([^_]+)$/)
      #      reader = @adapters[m[1].to_sym]
      #      if reader.respond_to?("from_#{m[2]}")
      #        return [reader, :"from_#{m[2]}"]
      #      end
      #    end
      #    return [@adapters[split_m.last.to_sym], nil]
      #  when 'as'
      #    if emitter = @adapters[split_m.last.to_sym]
      #      return [emitter, nil]
      #    end
      #  end
      #  nil
      #end

      def method_missing(m, *args, &blk)
        method_s = m.to_s
        case method_s
        when /(from|wrap)_([^_]+)_(.*)$/
          @from = @factory.adapters[$2.to_sym].send(:"from_#{$3}", *args, &blk)
          $1 == 'wrap' ? @from : self
        when /(from|wrap)_([^_]+)$/
          adapter = @factory.adapters[$2.to_sym]
          @from = if adapter.respond_to?(:decode)
            adapter.decode(*args, &blk)
          else
            adapter.create(*args, &blk)
          end
          $1 == 'wrap' ? @from : self
        when /as_([^_]+)$/
          raise unless @from
          @to_class = @factory.adapters[$1.to_sym]
          execute
          to_representation = if @to.respond_to?(:encode)
            @to.encode(*args, &blk)
          else
            @to.obj
          end
          to_representation
        else
          super
        end
      end

      def list(name, binding, opts = nil)
        bind = @factory.bindings[binding].new
        bind.to_class = to_class
        to_array = []
        from_val = @from.get_list(name)
        from_val.get_list_size.times do |i|
          bind.to = nil
          bind.from = from_val.get_list_object(i)
          bind.execute
          to_array << bind.to.obj
        end
        @attrs[name] = bind.to_class.create_list(to_array).obj
      end

      def object(name, binding, opts = nil)
        bind = @factory.bind_object(binding)
        bind.to_class = to_class
        bind.from = @from.get_object(name)
        bind.execute
        @attrs[name] = bind.to.obj
      end

      private
      def execute_list
        raise unless @validate_type == :list or @validate_type.nil?
        @attrs = []
        instance_eval(&@blk)
        @to = to_class.list(@attrs)
      end

      def execute_object
        raise unless @validate_type == :object or @validate_type.nil?
        @attrs = {}
        instance_eval(&@blk)
        @to = to_class.object(@attrs)
      end
    end
  end
end
