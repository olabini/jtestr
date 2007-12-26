$:.unshift File.join(File.dirname(__FILE__), '..', 'mocha', 'lib')

require 'mocha'

module JtestR
  module Mocha
    METHODS_TO_LEAVE_ALONE = [
                              # Things for internal Ruby
                              '__id__', '__send__', '__metaclass__', '==', 
                              'equals', 'respond_to?', 'class', 'methods', 
                              # Things for Java Integration
                              '__jcreate!', '__jsend!', 'java_object=', 'java_object', 
                              'to_java_object',
                              # Things for Mocha
                              'mocha', 'reset_mocha', 'stubba_method', 
                              'stubba_object', 'expects', 'stubs', 'verify']
  end
end


module Mocha
  module AutoVerify
    alias old_mock mock
    
    def mock(*args)
      if args.first.is_a?(Module)
        type = args.first
        case type
        when Class
          c = type.instance_variable_get :@mocking_class
          unless c
            c = Class.new(type)
            c.class_eval do 
              undef_method *(public_instance_methods - JtestR::Mocha::METHODS_TO_LEAVE_ALONE)
            end
            type.instance_variable_set :@mocking_class, c
          end
          c.new
        when Module
          type.new
        end
      else
        old_mock(*args)
      end
    end
  end
end
