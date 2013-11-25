Sidekiq Priority
================
Prioritize Sidekiq jobs within queues

[![Build Status](https://travis-ci.org/socialpandas/sidekiq-priority.png)](https://travis-ci.org/socialpandas/sidekiq-priority)

Overview
--------

Sidekiq Priority lets you prioritize the jobs within any Sidekiq queue.

For example, say you add 5 jobs with the default priority:

```ruby
5.times.do
  MyWorker.perform_async(42)
end
```

Using Sidekiq Priority, you can add new jobs that have a higher priority than those original 5 jobs by calling perform_with_priority instead of perform_async:

```ruby
MyWorker.perform_with_priority(:high, 42)
```

This job won't interrupt any running jobs, but it'll start before any other jobs in the queue do.

You can also add jobs that should only run with lower priority than the default priority:

```ruby
MyWorker.perform_with_priority(:low, 42)
```

Installation
------------

Include it in your Gemfile:

    gem 'sidekiq-priority'

Custom Priorities
------------

By default, two priorities are available: `:high` (above the default prioritization of perform_async) and `:low` (below the default prioritization of perform_async), but you can add others (these values should be symbols, and `nil` represents the default prioritization):

```ruby
# config/initializers/sidekiq_priority.rb
Sidekiq::Priority.priorities = [:very_high, :high, nil, :low]
```

License
-------

Sidekiq Priority is released under the MIT License. Please see the MIT-LICENSE file for details.
