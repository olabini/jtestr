JtestR::LoadStrategy.load(File.join(File.dirname(__FILE__), '..', 'mocha', 'lib'), 'mocha')

module JtestR
  module Mocha
    METHODS_TO_LEAVE_ALONE = [
                              # Things for internal Ruby
                              '__id__', '__send__', '__metaclass__', '==', 'inspect',
                              '__is_a__', 'equals', 'respond_to?', 'class', 'methods', 
                              'send', 'equal?', 'eql?', 'to_s', 'object_id',
                              'public_methods', 'protected_methods', 'private_methods',
                              # Things for Java Integration
                              '__jcreate!', '__jsend!', 'java_object=', 'java_object', 
                              'to_java_object', 'initialize',
                              # Things for Mocha
                              'mocha', 'reset_mocha', 'stubba_method', 
                              'stubba_object', 'expects', 'stubs', 'verify',
                              # Things for RSpec
                              'should', 'should_not',
                              # Things for Expectations
                              '__which_expects__', '__which_expects__='
                              
                             ]
    def self.revert_mocking(clazz)
      clazz.instance_variable_set :@mocking_classes, nil
    end
    
    def self.create_mocking(clazz, preserved_methods = JtestR::Mocha::METHODS_TO_LEAVE_ALONE)
      preserved_methods = preserved_methods.is_a?(Symbol) ? preserved_methods : preserved_methods.sort.uniq
      case clazz
      when Class
        c = clazz.instance_variable_get :@mocking_classes
        unless c
          c = { }
          clazz.instance_variable_set :@mocking_classes, c
        end
        unless c[preserved_methods]
          clz = Class.new(clazz)
          clz.class_eval do 
            undef_method *(public_instance_methods - preserved_methods)
          end unless preserved_methods == :preserve_all
          c[preserved_methods] = clz
        end
      when Module
        # Maybe actually implement methods for modules here, at some point? Hmm

        c = clazz.instance_variable_get :@mocking_classes
        unless c
          c = { }
          clazz.instance_variable_set :@mocking_classes, c
        end
        unless c[preserved_methods]
          clz = Class.new
          clz.send :include, clazz
          clz.class_eval do 
            undef_method *(public_instance_methods - preserved_methods)
          end unless preserved_methods == :preserve_all
          c[preserved_methods] = clz
        end
      end
    end
    
    def self.mocking_class(clazz, preserved_methods = JtestR::Mocha::METHODS_TO_LEAVE_ALONE)
      preserved_methods = preserved_methods.is_a?(Symbol) ? preserved_methods : preserved_methods.sort.uniq
      create_mocking(clazz, preserved_methods)
      clazz.instance_variable_get(:@mocking_classes)[preserved_methods]
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
  module Standalone
    alias old_mock mock
    
    def mock(*args)
      if args.first.is_a?(Module)
        JtestR::Mocha::mocking_class(*args).new
      else
        old_mock(*args)
      end
    end

    def mock_class(*args)
      JtestR::Mocha::mocking_class(*args)
    end
    
    def jstub(type, hash = {})
      mock = mock(type)

      hash.each do |key, value|
        mock.stubs(key).returns(value)
      end
      
      mock
    end
  end
end
