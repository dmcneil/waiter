require 'rspec/expectations'

require_relative 'timeout_error'

module Waiter
  # Wrapper for RSpec expectations that allows waiting/polling.
  #
  # The default timeout is 15 seconds, polling every 1 second.
  #
  # @example
  #
  #   wait.for('foo').to eq 'foo' # Will pass.
  #   wait.for('foo').to eq 'bar' # Will throw exception.
  #   wait.for('foo').to_not eq 'bar' # Will pass.
  #   wait.for('foo').to_not eq 'foo' # Will fail.
  #
  # To adjust the timeout/polling, simple chain methods are supported.
  #
  # The *up_to* method accepts an Integer and adjusts the timeout.
  # Use the *every* method with an Integer to adjust the polling time.
  #
  # @example
  #
  #   # Wait for 30 seconds, polling every 2 second.
  #   wait.every(2).up_to(30).for('foo').to eq 'foo'
  #
  # You do *not* have to use both methods, you can adjust one or the other.
  # They can also be used in any order.
  #
  # @example
  #
  #   # Wait for 30 seconds, using the default 1 second poll.
  #   wait.for('foo').up_to(30).to eq 'foo'
  #
  #   # Wait for the default 15 seconds, polling every 5 seconds.
  #   wait.for('foo').every(5).to eq 'foo'
  #
  # You can also pass a block to be evaluated, using *until*, until it is true.
  #
  # @example
  #
  #   wait.until { true == true }
  #
  #   wait.every(5).up_to(30).until {
  #     true == true
  #   }
  #
  # @author Derek McNeil <dmcneil@pindrop.com>
  def wait(opts = {}, &block)
    ChainableWait.new(opts)
  end

  class ChainableWait
    attr_reader :target
    attr_accessor :timeout, :polling, :message

    DEFAULT_TIMEOUT = 15
    DEFAULT_POLLING = 1

    def initialize(opts = {})
      @timeout = opts[:timeout] || DEFAULT_TIMEOUT
      @polling = opts[:polling] || DEFAULT_POLLING
      @failure_message = opts[:failure_message]
    end

    def for(value = nil, &block)
      if value
        @target = value
      elsif block_given?
        @target = block
      end

      self
    end

    def up_to(seconds)
      @timeout = seconds
      self
    end

    def every(seconds)
      @polling = seconds
      self
    end
    alias_method :polling_every, :every

    def fail_with(message)
      @failure_message = message
      self
    end

    def to(matcher = nil, &block)
      WaitExpectationTarget.new(@target).to(self, matcher, &block)
    end

    def not_to(matcher = nil, &block)
      WaitExpectationTarget.new(@target).not_to(self, matcher, &block)
    end
    alias_method :to_not, :not_to

    def until(&block)
      unless @timeout > @polling
        raise ArgumentError, 'Timeout must be a higher value than polling.'
      end

      current_timeout = @timeout

      while current_timeout > 0 && current_timeout > @polling
        trap('SIGINT') { break }

        @result = begin
          block.call
        rescue SystemExit, Interrupt
          break
        rescue Exception => error
          @error = error
          false
        end

        break if @result
        sleep @polling
        current_timeout = current_timeout - @polling
      end

      unless @result
        if @error
          @error = Waiter::TimeoutError.new(build_error(@error))
        else
          @error = Waiter::TimeoutError.new(build_error)
        end

        raise @error
      end
    end

    private

    def build_error(error = nil)
      [
        @failure_message,
        "Timed out after waiting for #{@timeout}s.",
        "Polled every #{@polling}s.",
        error
      ].join("\n")
    end
  end

  class WaitExpectationTarget < RSpec::Expectations::ExpectationTarget
    def to(waiter, matcher = nil, &block)
      prevent_operator_matchers(:to) unless matcher
      waiter.until do
        target = handle_target(waiter.target)
        RSpec::Expectations::PositiveExpectationHandler.handle_matcher(target,
                                                                       matcher,
                                                                       &block)

        return target
      end
    end

    def not_to(waiter, matcher = nil, &block)
      prevent_operator_matchers(:not_to) unless matcher
      waiter.until do
        target = handle_target(waiter.target)
        RSpec::Expectations::NegativeExpectationHandler.handle_matcher(target,
                                                                       matcher,
                                                                       &block)

        return target
      end
    end

    private

    def handle_target(target)
      if target.respond_to?(:call)
        target.call
      else
        target
      end
    end
  end
end
