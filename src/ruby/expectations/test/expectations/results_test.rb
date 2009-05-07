require File.dirname(__FILE__) + "/../test_helper"

Expectations do
  expect Object.new.extend(Expectations::Results::Fulfilled).to.have.char == "."
  expect Object.new.extend(Expectations::Results::StateBasedFailure).to.have.char == "F"
  expect Object.new.extend(Expectations::Results::BehaviorBasedFailure).to.have.char == "F"
  expect Object.new.extend(Expectations::Results::Error).to.have.char == "E"
  expect Object.new.extend(Expectations::Results::Fulfilled).to.be.fulfilled?
  expect Object.new.extend(Expectations::Results::StateBasedFailure).not.to.be.fulfilled?
  expect Object.new.extend(Expectations::Results::BehaviorBasedFailure).not.to.be.fulfilled?
  expect Object.new.extend(Expectations::Results::Error).not.to.be.fulfilled?
  expect Object.new.extend(Expectations::Results::Fulfilled).not.to.be.error?
  expect Object.new.extend(Expectations::Results::StateBasedFailure).not.to.be.error?
  expect Object.new.extend(Expectations::Results::BehaviorBasedFailure).not.to.be.error?
  expect Object.new.extend(Expectations::Results::Error).to.be.error?
  expect Object.new.extend(Expectations::Results::Fulfilled).not.to.be.failure?
  expect Object.new.extend(Expectations::Results::StateBasedFailure).to.be.failure?
  expect Object.new.extend(Expectations::Results::BehaviorBasedFailure).to.be.failure?
  expect Object.new.extend(Expectations::Results::Error).not.to.be.failure?
end