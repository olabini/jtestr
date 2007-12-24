
require 'test/unit/ui/testrunnermediator'

module JtestR
  class TestUnitResultHandler
    def initialize(suite, io=STDOUT)
      if (suite.respond_to?(:suite))
        @suite = suite.suite
      else
        @suite = suite
      end
      @io = io
    end

    def self.run(suite, ignored=nil)
      runner = new(suite)
      runner.instance_variable_set(:@result_handler, @result_handler)
      runner.start
    end
    
    # Begins the test run.
    def start
      setup_mediator
      attach_to_mediator
      return start_mediator
    end

    private
    def setup_mediator
      @mediator = create_mediator(@suite)
    end
    
    def create_mediator(suite)
      return Test::Unit::UI::TestRunnerMediator.new(suite)
    end
    
    def attach_to_mediator
      @mediator.add_listener(Test::Unit::TestResult::FAULT, &method(:add_fault))
      @mediator.add_listener(Test::Unit::TestCase::STARTED, &method(:test_started))
      @mediator.add_listener(Test::Unit::TestCase::FINISHED, &method(:test_finished))
      @mediator.add_listener(Test::Unit::UI::TestRunnerMediator::STARTED, &method(:started))
      @mediator.add_listener(Test::Unit::UI::TestRunnerMediator::FINISHED, &method(:finished))
    end
    
    def start_mediator
      return @mediator.run_suite
    end
    
    def started(result)
      @result_handler.starting
    end
    
    def finished(elapsed_time)
      @result_handler.ending
    end
    
    def add_fault(fault)
      @result_handler.add_fault(fault)
      
      if defined?(Spec) && 
          fault.respond_to?(:exception) && 
          Spec::Expectations::ExpectationNotMetError === fault.exception
        @result_handler.fail_single
      else
        case fault.single_character_display
        when 'F': @result_handler.fail_single
        when 'E': @result_handler.error_single
        end
      end

      @already_outputted = true
    end

    def test_started(name)
      @result_handler.starting_single(name)
    end
    
    def test_finished(name)
      @result_handler.succeed_single(name) unless (@already_outputted)
      @already_outputted = false
    end
  end
end
