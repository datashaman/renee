module Renee
  module Util
    def self.lookup_constant(str)
      str.split('::').inject(Kernel) {|memo, name| memo.const_get(name)}
    end
  end
end
