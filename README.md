# Wait

A simple wait/polling gem.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'wait', git: 'git@github.atl.pdrop.net:dmcneil/wait.git'
```

And then execute:

    $ bundle install

## Usage

Just `include Wait` and the following APIs will be available.

```ruby
wait('foo').to eq 'foo' # Will pass.
wait('foo').to eq 'bar' # Will throw exception.
wait('foo').to_not eq 'bar' # Will pass.
wait('foo').to_not eq 'foo' # Will fail.
```

To adjust the timeout/polling, simple chain methods are supported.

The *for* method accepts an Integer and adjusts the timeout. Use the *every* method with an Integer to adjust the polling time.

```ruby
# Wait for 30 seconds, polling every 2 second.
wait('foo').every(2).for(30).to eq 'foo'
```

You do *not* have to use both methods, you can adjust one or the other. They can also be used in any order.

```ruby
# Wait for 30 seconds, using the default 1 second poll.
wait('foo').for(30).to eq 'foo'

# Wait for the default 15 seconds, polling every 5 seconds.
wait('foo').every(5).to eq 'foo'
```

You can also pass a block to be evaluated, using *until*, until it is true.

```ruby
wait.until { true == true }

wait.every(5).for(30).until {
  true == true
}
```

