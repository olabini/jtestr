
module JtestR
  class Factories
    class << self
      attr_accessor :factories
      
      def add_factory(spec, block)
        self.factories << Factories.new(spec, block)
      end
    end
    
    module KernelMethods
      def factory_for(*spec, &block)
        Factories.add_factory spec, block
      end
    end
    
    def initialize(spec, block)
      @spec = spec
      @module = Module.new(&block)
    end
  end
end

class Object
  include JtestR::Factories::KernelMethods
end

JtestR::Factories.factories = []
