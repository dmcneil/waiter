require 'spec_helper'

describe Waiter do
  let(:wait) do
    class Foo
      include Waiter
    end
    Foo.new.wait(timeout: 3, polling: 1)
  end

  it 'waits for true' do
    expect {
      wait.for('foo').to eq 'foo'
    }.to_not raise_error
  end

  it 'raises an error on timeout' do
    expect {
      wait.for('foo').to eq 'bar'
    }.to raise_error Waiter::TimeoutError
  end

  it 'allows to_not or not_to' do
    expect(wait.for(nil)).to respond_to :to_not, :not_to
  end

  it 'allows until' do
    expect(wait).to respond_to :until
  end

  it 'can set the timeout' do
    expect(wait).to respond_to :up_to
    wait.up_to(5)
    expect(wait.timeout).to eq 5
  end

  it 'can set the polling' do
    expect(wait).to respond_to :every
    wait.every(5)
    expect(wait.polling).to eq 5
  end

  it 'can be used to wait for a block to be true' do
    expect {
      wait.for { true == true }.to be true
    }.to_not raise_error
  end

  it 'raises an error if a block isnt true' do
    expect {
      wait.for { true == false }.to eq true
    }.to raise_error Waiter::TimeoutError
  end

  it 'returns the target on #to success' do
    result = wait.for('foo').to eq 'foo'
    expect(result).to eq 'foo'
  end

  it 'returns the target on #to_not success' do
    result = wait.for('foo').to_not eq 'bar'
    expect(result).to eq 'foo'
  end

  it 'can be used without an rspec matcher' do
    expect {
      wait.until do
        true == true
      end
    }.to_not raise_error
  end

  it 'will not throw an error using until' do
    expect {
      wait.until do
        true == false
      end
    }.to raise_error Waiter::TimeoutError
  end
end
