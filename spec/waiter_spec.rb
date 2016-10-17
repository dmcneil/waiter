require 'spec_helper'

describe Waiter do
  include Waiter

  before do
    Waiter::WaitExpectationTarget::DEFAULT_TIMEOUT = 5
    Waiter::WaitExpectationTarget::DEFAULT_POLLING = 1
  end

  it 'waits for true' do
    begin
      wait('foo').to eq 'bar'
    rescue Exception
      # intended
    end

    expect {
      wait('foo').to eq 'foo'
    }.to_not raise_error, RSpec::Expectations::ExpectationNotMetError
  end

  it 'raises an error on timeout' do
    expect {
      wait('foo').to eq 'bar'
    }.to raise_error, RSpec::Expectations::ExpectationNotMetError
  end

  it 'allows to_not or not_to' do
    expect(wait(nil)).to respond_to :to_not, :not_to
  end

  it 'allows until' do
    expect(wait).to respond_to :until
  end

  it 'can set the timeout' do
    wait = wait(nil)
    expect(wait).to respond_to :for
    wait.for(5)
    expect(wait.timeout).to eq 5
  end

  it 'can set the polling' do
    wait = wait(nil)
    expect(wait).to respond_to :every
    wait.every(5)
    expect(wait.polling).to eq 5
  end

  it 'can be used to wait for a block to be true' do
    expect {
      wait.until { true == true }
    }.to_not raise_error RuntimeError
  end

  it 'raises an error if a block isnt true' do
    expect {
      wait.until { true == false }
    }.to raise_error RuntimeError
  end

  it 'returns the target on #to success' do
    result = wait('foo').to eq 'foo'
    expect(result).to eq 'foo'
  end

  it 'returns the target on #to_not success' do
    result = wait('foo').to_not eq 'bar'
    expect(result).to eq 'foo'
  end
end
