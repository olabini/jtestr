module JtestR
  class RSpecHelperFormatter < ::Spec::Runner::Formatter::BaseFormatter
    def initialize;end
    
    def example_group_started(example_group)
      JtestR::Helpers.apply([example_group])
      @example_group = example_group
    end
  end
end
