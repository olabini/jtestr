require 'jtestr/rspec_helper_formatter'

module JtestR
  class RSpecStoryResultHandler < RSpecHelperFormatter
    def initialize(result_handler)
      @result_handler = result_handler
    end
    
    def run_started(count)
      @result_handler.starting
    end
    
    def story_started(title, narrative)
    end

    def scenario_started(story_title, scenario_name)
      @result_handler.starting_single("#{scenario_name}(#{story_title})")
    end
    
    def scenario_succeeded(story_title, scenario_name)
      @result_handler.succeed_single(scenario_name)
    end

    def scenario_failed(story_title, scenario_name, err)
      @result_handler.add_fault(err)
      if err.exception.is_a?(::Spec::Expectations::ExpectationNotMetError)
        @result_handler.fail_single(scenario_name)
      else
        @result_handler.error_single(scenario_name)
      end
    end    
    
    def scenario_pending(story_title, scenario_name, msg)
      @result_handler.add_pending("#{scenario_name}(#{story_title}): #{msg}")
      @result_handler.pending_single(scenario_name)
    end

    def story_ended(title, narrative)
    end
    
    def collected_steps(steps)
    end
    
    def run_ended
      @result_handler.ending
    end
    
    def method_missing(sym, *args, &block) #:nodoc:
      # noop - ignore unknown messages
    end
  end
end
