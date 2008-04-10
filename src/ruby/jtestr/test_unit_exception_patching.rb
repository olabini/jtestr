
module Test
  module Unit
    module Assertions
      def _check_exception_class(args) # :nodoc:
        args.partition do |klass|
          next if klass.instance_of?(Module)
          assert(Exception >= klass || java.lang.Throwable >= klass, "Should expect a class of exception, #{klass}")
          true
        end
      end
      
      alias old_expected_exception _expected_exception?
  
      def _expected_exception?(actual_exception, exceptions, modules) # :nodoc:
        old_expected_exception(actual_exception, exceptions, modules) or
          (actual_exception.is_a?(NativeException) && 
           (exceptions.include?(actual_exception.cause.class) ||
            modules.any? {|mod| actual_exception.cause.is_a?(mod)})
           )
      end
    end
  end
end
