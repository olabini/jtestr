module Expectations::StateBasedExpectation
  def execute
    begin
      mocha_setup
      self.actual = instance_eval(&block)
      return self.extend(Expectations::Results::Fulfilled) if expected.expectations_equal_to(actual)
    rescue Exception => ex
      return self.extend(Expectations::Results::Fulfilled) if expected == ex.class
      self.extend(Expectations::Results::Error)
      self.exception = ex 
      self.message = "expected: <#{expected.inspect}> got: <#{ex.class.inspect}>" if expected.is_a?(Class) && expected < StandardError
      return self
    ensure
      mocha_teardown
    end
    self.extend(Expectations::Results::StateBasedFailure)
  end
end