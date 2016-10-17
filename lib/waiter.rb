require 'rspec/expectations'

module Waiter
  # Wrapper for RSpec expectations that allows waiting/polling.
  #
  # The default timeout is 15 seconds, polling every 1 second.
  #
  # @example
  #
  #   wait('foo').to eq 'foo' # Will pass.
  #   wait('foo').to eq 'bar' # Will throw exception.
  #   wait('foo').to_not eq 'bar' # Will pass.
  #   wait('foo').to_not eq 'foo' # Will fail.
  #
  # To adjust the timeout/polling, simple chain methods are supported.
  #
  # The *for* method accepts an Integer and adjusts the timeout.
  # Use the *every* method with an Integer to adjust the polling time.
  #
  # @example
  #
  #   # Wait for 30 seconds, polling every 2 second.
  #   wait('foo').every(2).for(30).to eq 'foo'
  #
  # You do *not* have to use both methods, you can adjust one or the other.
  # They can also be used in any order.
  #
  # @example
  #
  #   # Wait for 30 seconds, using the default 1 second poll.
  #   wait('foo').for(30).to eq 'foo'
  #
  #   # Wait for the default 15 seconds, polling every 5 seconds.
  #   wait('foo').every(5).to eq 'foo'
  #
  # You can also pass a block to be evaluated, using *until*, until it is true.
  #
  # @example
  #
  #   wait.until { true == true }
  #
  #   wait.every(5).for(30).until {
  #     true == true
  #   }
  #
  # @author Derek McNeil <dmcneil@pindrop.com>
  def wait(value=true, &block)
    WaitExpectationTarget.for(value, block)
  end

  alias_method :wait_for, :wait

  class WaitExpectationTarget < RSpec::Expectations::ExpectationTarget
    attr_reader :target
    attr_accessor :timeout, :polling, :message

    DEFAULT_TIMEOUT = 15
    DEFAULT_POLLING = 1

    def initialize(value)
      @target = value
      @timeout = DEFAULT_TIMEOUT
      @polling = DEFAULT_POLLING
    end

    def wait(message=nil, &block)
      unless @timeout > @polling
        raise ArgumentError, 'Timeout must be a higher value than polling.'
      end

      @message = message || default_failure_message

      while @timeout > 0 && @timeout > @polling
        @result = begin
          block.call
        rescue Exception => error
          @error = error
          false
        end

        break if @result
        sleep @polling
        @timeout = @timeout - @polling
      end

      unless @result
        if @error
          @error.message.prepend @message
        else
          @error = RuntimeError.new @message
        end

        raise @error
      end
    end

    alias_method :until, :wait

    def every(seconds)
      @polling = seconds
      self
    end

    def for(seconds)
      @timeout = seconds
      self
    end

    def to(matcher=nil, message=nil, &block)
      prevent_operator_matchers(:to) unless matcher
      wait(message) do
        RSpec::Expectations::PositiveExpectationHandler.handle_matcher(target, matcher, message, &block)
      end
      @target
    end

    def not_to(matcher=nil, message=nil, &block)
      prevent_operator_matchers(:not_to) unless matcher
      wait(message) do
        RSpec::Expectations::NegativeExpectationHandler.handle_matcher(target, matcher, message, &block)
      end
      @target
    end

    alias_method :to_not, :not_to

    def default_failure_message
      "Timed out after waiting for #{@timeout} seconds, polling every #{@polling} second.\n"
    end
  end
end
