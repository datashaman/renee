module Renee
  class Core
    module Plugins
      attr_reader :init_blocks, :before_blocks, :after_blocks

      def on_init(&blk)
        init_blocks << blk
      end

      def init_blocks
        (@init_blocks ||= [])
      end

      def on_before(&blk)
        before_blocks << blk
      end

      def before_blocks
        (@before_blocks ||= [])
      end

      def on_after(&blk)
        before_blocks << blk
      end

      def after_blocks
        (@after_blocks ||= [])
      end
    end
  end
end