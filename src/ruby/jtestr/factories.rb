
module JtestR
  class Factories
    class << self
      attr_accessor :factories
      
      def add_factory(spec, block)
        self.factories << Factories.new(spec, block)
      end
      
      def before(instance)
        @__factories_instance_variables = []
        factories.each do |f|
          res = f.apply_on(instance)
          @__factories_instance_variables += res
        end
        
        if instance.is_a?(Test::Unit::TestCase)
#          puts "T/U FACTORY CALL: #{instance.class.name}##{instance.method_name}"
        else
#          puts "RSP FACTORY CALL: #{instance.class.description}##{instance.description}"
        end
      end
      
      def after(instance)
        @__factories_instance_variables.each do |fiv|
          instance.instance_variable_set fiv, nil
        end
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
      @creations = @module.public_instance_methods.select{ |m| m=~ /\Acreate_/ }.map{ |m| m[7..-1] }
    end
    
    def apply_on(instance)
      []
    end
  end
end

class Object
  include JtestR::Factories::KernelMethods
end

JtestR::Factories.factories = []

module Test
  module Unit
    class TestCase      
      # This is a bit ugly, but since Test::Unit doesn't allow you access to the actual instance
      # in the hooks, it's the only way to do it neatly.
      def run(result)
        yield(STARTED, name)
        @_result = result
        begin
          __test_unit_internal_setup
          setup
          __send__(@method_name)
        rescue AssertionFailedError => e
          add_failure(e.message, e.backtrace)
        rescue StandardError, ScriptError
          add_error($!)
        ensure
          begin
            teardown
          rescue AssertionFailedError => e
            add_failure(e.message, e.backtrace)
          rescue StandardError, ScriptError
            add_error($!)
          ensure
            __test_unit_internal_teardown
          end
        end
        result.add_run
        yield(FINISHED, name)
      end

      def __test_unit_internal_setup
        JtestR::Factories.before(self)
      end
      
      def __test_unit_internal_teardown
        JtestR::Factories.after(self)
      end
    end
  end
end

module Spec
  module Example
    class ExampleGroup
      before(:each) do 
        JtestR::Factories.before(self)
      end
      
      after(:each) do 
        JtestR::Factories.after(self)
      end
    end
  end
end
