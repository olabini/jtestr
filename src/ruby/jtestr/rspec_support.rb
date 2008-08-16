$:.unshift File.join(File.dirname(__FILE__), '..', 'rspec', 'lib')

require 'spec'
require 'spec/runner/formatter/base_formatter'
require 'spec/story'
module Spec
  module Story
    module Runner
      class << self
        def register_exit_hook # :nodoc:
        end
      end
    end
  end
end

require 'jtestr/rspec_result_handler'
require 'jtestr/rspec_story_result_handler'

Spec::Runner.configure do |config|
  config.mock_with :mocha
end


module JtestR
  ::Spec::Example::OldExampleMatcher = ::Spec::Example::ExampleMatcher

  class RSpecFilterMatcher < ::Spec::Example::OldExampleMatcher
    def initialize(example_group_description, example_name)
      @example_group_description = example_group_description
      @example_name = example_name
    end
    
    def matches?(spec)
      spec.is_a?(Array) && spec.all? do |s|
        s.is_a?(::JtestR::RSpecFilter)
      end ? spec.all? { |s| s.accept?(@example_group_description, @example_name) } : super
    end
  end
  
  class << ::Spec::Example::ExampleMatcher
    def new(*args)
      matcher = JtestR::RSpecFilterMatcher.allocate
      matcher.send :initialize, *args
      matcher
    end
  end

  class RSpecFilter
    def initialize(filters)
      @filters = filters
    end

    def accept?(description, name)
      @filters.all? do |f|
        f.accept?(description, name)
      end
    end

    # This one will never return a string that returns true for File.file? ... hopefully
    def to_str
      "!!!!!!!!!!!!!!!!!!!!!!!"
    end
  end
  
  module RSpecTestRunning
   def add_rspec_groups(group, match_info)
      files = choose_files(@specs, match_info)
      files.sort!
      group << files
    end

   def add_rspec_story_groups(group)
      files = @stories
      files.sort!
      group << files
    end

    def run_rspec(group, aggr)
      name = group.name
      files = group.files

      unless files.empty?
        log.debug { "running rspec[#{name}] on #{files.inspect}" }

        out = StringIO.new

        parser = ::Spec::Runner::OptionParser.new(out, out)
        parser.order!(files)
        options = parser.options

        options.parse_example(RSpecFilter.new(@test_filters)) if !@test_filters.empty?

        result_handler = JtestR.result_handler.new(name, "example", @output, @output_level, aggr)
        
        formatters = load_spec_formatters(options, result_handler)
        
        options.instance_variable_set :@formatters, formatters

        res = ::Spec::Runner::CommandLine.run(options)

        @result &= res
      end
    rescue Exception => e
      log.err e.inspect
      log.err e.backtrace
      raise
    end
    
    def run_rspec_stories(group, aggr)
      name = group.name
      files = group.files
      
      unless (files.empty? && @configuration.configuration_values(:stories).empty?) || !@test_filters.empty?
        log.debug { "running stories[#{name}] on #{files.inspect}" }
        
        Spec::Story::Runner.run_options.reporter = []

        result_handler = JtestR.result_handler.new(name, "scenario", @output, @output_level, aggr)

        options = Spec::Story::Runner.run_options
        formatters = load_story_formatters(options, result_handler)
        options.instance_variable_set :@formatters, formatters

        Spec::Story::Runner.story_runner.stories = []

        files.each do |file|
          guard("while loading #{file}") { load file }
        end

        Spec::Story::Runner.story_runner.run_stories
        
        @result &= !result_handler.failed?
      end
    rescue Exception => e
      log.err e.inspect
      log.err e.backtrace
      raise
    end

    def load_spec_formatters(options, result_handler)
      rspec_formatters = @configuration.configuration_values(:rspec_formatter)
      formatters = rspec_formatters.map { |name, where|
        if val = ::Spec::Runner::Options::EXAMPLE_FORMATTERS[name]
          require val[0]
          eval("::Spec::Runner::" + val[1], binding, __FILE__, __LINE__).new(options, transform_spec_where(where || @output))
        else
          if Class === name
            name.new(options, transform_spec_where(where || @output))
          elsif String === name
            eval(name, binding, __FILE__, __LINE__).new(options, transform_spec_where(where || @output))
          else
            name
          end
        end
      }
      unification = @configuration.configuration_values(:unify_rspec_output).flatten
      unification = unification.empty? ? true : unification.first
      formatters << (!unification ? RSpecHelperFormatter.new : RSpecResultHandler.new(result_handler))
      formatters
    end

    def load_story_formatters(options, result_handler)
      story_formatters = @configuration.configuration_values(:story_formatter)
      formatters = story_formatters.map { |name, where|
        if val = ::Spec::Runner::Options::STORY_FORMATTERS[name]
          require val[0]
          eval("::Spec::Runner::" + val[1], binding, __FILE__, __LINE__).new(options, transform_spec_where(where || @output))
        else
          if Class === name
            name.new(options, transform_spec_where(where || @output))
          elsif String === name
            eval(name, binding, __FILE__, __LINE__).new(options, transform_spec_where(where || @output))
          else
            name
          end
        end
      }
      unification = @configuration.configuration_values(:unify_story_output).flatten
      unification = unification.empty? ? true : unification.first
      formatters << (!unification ? RSpecHelperFormatter.new : RSpecStoryResultHandler.new(result_handler))
      formatters
    end
    
    def transform_spec_where(where)
      if where == STDOUT
        @output
      elsif where == STDERR
        @output
      else
        where
      end
    end
  end
end
