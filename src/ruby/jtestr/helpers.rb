
module JtestR
  class Helpers
    class << self
      attr_accessor :helpers
      
      def add_helper(type_spec, block)
        self.helpers << Helpers.new(type_spec, block)
      end
      
      def apply(available_classes)
        self.helpers.each do |h| 
          h.apply(available_classes)
        end
      end
    end
    
    module KernelMethods
      def helper_for(*args, &block)
        args.each do |type_spec|
          Helpers.add_helper type_spec, block
        end
      end
    end
    
    def initialize(type_spec, block)
      @type_spec = type_spec
      @module = Module.new(&block)
    end
    
    def apply(available_classes)
      case @type_spec
      when Class
        ext(@type_spec)
      when Module
        ext_module(@type_spec)
      when Symbol
        t = eval(@type_spec.to_s) rescue nil
        case t
        when Class
          ext(t)
        when Module
          ext_module(t)
        end
      when Regexp
        available_classes.each do |c|
          if c.respond_to?(:name)  && c.name =~ @type_spec
            ext(c)
          end
        end
        Object.constants.each do |c|
          val = Object.const_get(c)
          if val.is_a?(Module) && val.respond_to?(:name) && val.name =~ @type_spec
            ext_module(val)
          end
        end
      end
    end
    
    def ext(type)
      type.send(:include, @module) unless type.is_a?(@module)
    end
    
    def ext_module(mod)
      ext(mod)
      mod.constants.each do |c|
        v = mod.const_get c
        if v.is_a?(Class)
          ext(v)
        end
      end
    end
  end
end

class Object
  include JtestR::Helpers::KernelMethods
end

JtestR::Helpers.helpers = []
