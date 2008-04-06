class Expectations::Expectation
  include Mocha::Standalone
  attr_accessor :expected, :block, :file, :line, :actual
  
  def initialize(expected, file, line, &block)
    self.expected, self.block = expected, block
    self.file, self.line = file, line.to_i
    case
      when expected.is_a?(Expectations::Recorder) then extend(Expectations::RecordedExpectation)
      else extend(Expectations::StateBasedExpectation)
    end
  end
  
end