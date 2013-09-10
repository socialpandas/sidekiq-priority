Sidekiq Priority
================
Prioritize Sidekiq jobs within queues

Overview
--------

Sidekiq Priority lets you prioritize the jobs within any Sidekiq queue.

For example, say you've added 5 jobs:

```ruby
5.times.do
  MyWorker.perform_async(42)
end
```

Using Sidekiq Priority, you can add new jobs that have a higher priority by calling perform_with_priority instead of perform_async:

```ruby
MyWorker.perform_with_priority(:high, 42)
```

This job won't interrupt any running jobs, but it'll start before any other jobs in the queue do.

You can also add jobs that should only run with lower priority than the default priority:

```ruby
MyWorker.perform_with_priority(:low, 42)
```

### Custom Priorities

By default, two priorities are available: `:high` (above the default prioritization of perform_async) and `:low` (below the default prioritization), but you can add others (these values should be symbols, and `nil` represents the default prioritization):

```ruby
# config/initializers/sidekiq_priority.rb
Sidekiq::Priorities.priorities = [:very_high, :high, nil, :low]
```

License
-------

Sidekiq Priority is released under the MIT License. Please see the MIT-LICENSE file for details.
