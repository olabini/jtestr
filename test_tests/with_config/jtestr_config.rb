value1 :abc, :cde
$__was_in_config = 42

junit "unit" => ['org.jtestr.test.JUnit3Test', 'org.jtestr.test.JUnit4Test']
junit ['org.jtestr.test.JUnit3Test']
junit 'org.jtestr.test.JUnit4Test'

testng "unit" => ['org.jtestr.test.TestNG1']

#groups['Unit JUnit'] << /JUnit3/

class FooLogger
  def initialize(*args)
    $__foo_logger_args = args
    @internal = JtestR::SimpleLogger.new(*args)
  end
  def method_missing(name, *args, &block)
    $__foo_logger_called = true
    @internal.send name, *args, &block
  end
end

class IgnoringResultHandler
  class << self
    def before
    end
    def after
    end
  end
  def initialize(name, type_name, output = STDOUT, level = DEFAULT, aggregator = nil)
    @name = name
    @level = level
    @output = output
    @type_name = type_name
    $__result_handler_args = [name, type_name, output, level]
    @internal = JtestR::GenericResultHandler.new(name, type_name, output, level, aggregator)
  end

  def starting_single(name = nil)
    $__ignoring_result_handler_have_started = true
    @internal.starting_single(name)
  end

  def method_missing(name, *args, &block)
    @internal.send name, *args, &block
  end
end

JtestR::logger = FooLogger
JtestR::result_handler = IgnoringResultHandler

classpath "build/test_classes2"
classpath "build/foobar.jar"
add_common_classpath true

# rspec :all
rspec Dir["#{File.dirname(__FILE__)}/specs/**/*.rb"]

# test_unit :all
test_unit File.dirname(__FILE__) + "/foo_spec.rb"

# expectations :all
expectations File.dirname(__FILE__) + "/expectations_spec.rb"
after do 
  raise "Should have run the correct tests" unless $__is_spec_ran && $__is_tu_ran
end

# can be any valid Ruby value, of course
output STDERR

# values are DEBUG, INFO, WARN, ERR
# can be specified as "ERR" or :ERR, or just JtestR::SimpleLogger::ERR
log_level "ERR"

# values are NONE, QUIET, NORMAL, VERBOSE, DEFAULT
# can be specified the same way as logging, exception with JtestR::GenericResultHandler::
output_level :NORMAL


class FakeFormatter
  def initialize(*args)
  end
  def method_missing(name, *args)
    $__fake_formatter_method_calls = true
  end
end

# unify_rspec_output false
#rspec_formatter ["s", STDOUT]
#rspec_formatter "s"
rspec_formatter FakeFormatter

helper File.dirname(__FILE__) + "/foobar.rb"
factory File.dirname(__FILE__) + "/foobar2.rb"
