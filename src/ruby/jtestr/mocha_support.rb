$:.unshift File.join(File.dirname(__FILE__), '..', 'mocha', 'lib')

require 'mocha'

module JtestR
  module Mocha
    METHODS_TO_LEAVE_ALONE = [
                              # Things for internal Ruby
                              '__id__', '__send__', '__metaclass__', '==', 'inspect',
                              '__is_a__', 'equals', 'respond_to?', 'class', 'methods', 
                              'send', 'equal?', 'eql?', 'to_s',
                              # Things for Java Integration
                              '__jcreate!', '__jsend!', 'java_object=', 'java_object', 
                              'to_java_object',
                              # Things for Mocha
                              'mocha', 'reset_mocha', 'stubba_method', 
                              'stubba_object', 'expects', 'stubs', 'verify',
                              # Things for RSpec
                              'should', 'should_not'
                             ]
    def self.revert_mocking(clazz)
      clazz.instance_variable_set :@mocking_class, nil
    end
    
    def self.create_mocking(clazz)
      case clazz
      when Class
        c = clazz.instance_variable_get :@mocking_class
        unless c
          c = Class.new(clazz)
          c.class_eval do 
            undef_method *(public_instance_methods - JtestR::Mocha::METHODS_TO_LEAVE_ALONE)
          end
          clazz.instance_variable_set :@mocking_class, c
        end
      when Module
        c = clazz.instance_variable_get :@mocking_class
        unless c
          c = Class.new
          c.send :include, clazz
          c.class_eval do 
            undef_method *(public_instance_methods - JtestR::Mocha::METHODS_TO_LEAVE_ALONE)
          end
          clazz.instance_variable_set :@mocking_class, c
        end
      end
    end
    
    def self.mocking_class(clazz)
      create_mocking(clazz)
      clazz.instance_variable_get :@mocking_class
    end
  end
end

class Module
  def any_instance
    if self.name =~ /^Java::/
      JtestR::Mocha::mocking_class(self).any_instance
    else 
      raise NotImplementedError, "any_instance only works for Modules that are Java interfaces"
    end
  end
end

class Class
  alias mocha_any_instance any_instance
  
  def any_instance
    if self.name =~ /^Java::/
      JtestR::Mocha::mocking_class(self).mocha_any_instance
    else
      mocha_any_instance
    end
  end
end

module Mocha
  module AutoVerify
    alias old_mock mock
    
    def mock(*args)
      if args.first.is_a?(Module)
        type = args.first
        JtestR::Mocha::mocking_class(type).new
      else
        old_mock(*args)
      end
    end
  end
end
