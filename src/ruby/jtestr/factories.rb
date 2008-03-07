
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
      @type_spec = spec.first
      @method_spec = spec[1] || {:tests => :all}
      @module = Module.new(&block)
      @creations = @module.public_instance_methods.select{ |m| m=~ /\Acreate_/ }.map{ |m| m[7..-1] }
      @instance_variables = @creations.map { |name| 
        "@#{name}".to_sym
      }
    end
    
    def apply_on(instance)
      check(@type_spec, instance) ? @instance_variables : []
    end

    def check(spec, instance)
      added = false
      case spec
      when :all
        added = added | add_factory_on(instance)
        added = added | add_factory_on(instance)
      when Symbol
        t = eval(spec.to_s) rescue nil
        case t
        when Class
          added = do_class(t, instance)
        when Module
          added = do_module(t, instance)
        end
      when String
        if instance.class.respond_to?(:description) && instance.class.description == spec
          added = add_factory_on(instance)
        end
      when Class
        added = do_class(spec, instance)
      when Module
        added = do_module(spec, instance)
      when Array
        added = @type_spec.map{ |s| check(s, instance) }.any?
      end
      added
    end

    def do_module(m, instance)
      added = false
      m.constants.each do |c|
        v = m.const_get c
        if v.is_a?(Class)
          added = added | add_factory_on(instance)
        end
      end
      added
    end
    
    def do_class(c, instance)
      add_factory_on(instance) if instance.is_a?(c)
    end
    
    def match_method_spec(instance, tests)
      case tests
      when :all
        true
      when Regexp
        ((instance.respond_to?(:description) && instance.description) || instance.method_name) =~ tests
      when Array
        tests.any? { |t| match_method_spec(instance, t) }
      when Proc
        tests[((instance.respond_to?(:description) && instance.description) || instance.method_name)]
      end
    end
    
    def add_factory_on(instance)
      if match_method_spec(instance, @method_spec["tests"] || @method_spec[:tests])
        unless instance.is_a?(@module)
          instance.send :extend, @module
        end
        @creations.each do |creation|
          val = instance.send :"create_#{creation}"
          instance.instance_variable_set :"@#{creation}", val
        end
        true
      else
        false
      end
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
          mocha_setup
          __test_unit_internal_setup
          setup
          __send__(@method_name)
          mocha_verify { add_assertion }
        rescue Mocha::ExpectationError => e
          add_failure(e.message, e.backtrace)
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
            mocha_teardown
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
