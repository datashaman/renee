module Renee
  module Util
    def self.lookup_constant(str)
      str.split('::').inject(Kernel) {|m, n| m.const_get(n)}
    end
  end
end