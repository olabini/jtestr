module Expectations::DelegateRecorder
  attr_accessor :delegation_result
  
  def delegate!(meth)
    @meth = meth
    recorder = self
    mod = Module.new do
      define_method meth do |*args|
        recorder.delegation_result = super
      end
    end
    subject.extend mod
  end
  
  def to(receiver)
    @receiver = receiver
    self
  end
  
  def subject!
    @subject_mock = Object.new
    @subject_mock.expects(@meth).returns(:a_delegated_return_value)
    subject.stubs(@receiver).returns(@subject_mock)
    subject
  end
  
  def verify
    :a_delegated_return_value == delegation_result
  end
  
  def failure_message
    "expected #{subject}.#{@meth} to return the value of #{subject}.#{@receiver}.#{@meth}; however, #{subject}.#{@meth} returned #{delegation_result.inspect}"
  end
  
  def mocha_error_message(ex)
    "expected #{subject} to delegate #{@meth} to #{@receiver}; however, #{subject}.#{@meth} was never called -- #{ex}"
  end
  
end