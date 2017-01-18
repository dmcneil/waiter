# Waiter

A simple wait/polling gem.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'waiter_'
```

And then execute:

    $ bundle install

## Usage

Just `include Waiter` and the following APIs will be available.

```ruby
wait.for('foo').to eq 'foo' # Will pass.
wait.for('foo').to eq 'bar' # Will throw exception.
wait.for('foo').to_not eq 'bar' # Will pass.
wait.for('foo').to_not eq 'foo' # Will fail.
```

To adjust the timeout/polling, simple chain methods are supported.

The *up_to* method accepts an Integer and adjusts the timeout.
Use the *every* method with an Integer to adjust the polling time.

```ruby
# Wait for 30 seconds, polling every 2 second.
wait.for('foo').every(2).up_to(30).to eq 'foo'
```

You do *not* have to use both methods, you can adjust one or the other. They can also be used in any order.

```ruby
# Wait for 30 seconds, using the default 1 second poll.
wait.for('foo').up_to(30).to eq 'foo'

# Wait for the default 15 seconds, polling every 5 seconds.
wait.for('foo').every(5).to eq 'foo'
```

You can also pass a block to be evaluated, using *until*, until it is true.

```ruby
wait.until { true == true }

wait.every(5).up_to(30).until {
  true == true
}
```
