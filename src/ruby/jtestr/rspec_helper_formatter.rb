module JtestR
  class RSpecHelperFormatter < ::Spec::Runner::Formatter::BaseFormatter
    def initialize;end
    
    def add_example_group(example_group)
      JtestR::Helpers.apply([example_group])
      super
    end
  end
end
