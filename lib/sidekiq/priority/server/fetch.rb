require 'celluloid'
require 'sidekiq/fetch'

module Sidekiq
  module Priority
    module Server
      class Fetch < Sidekiq::BasicFetch
        def initialize(options)
          queues = prioritized_queues(options[:queues])
          @strictly_ordered_queues = !!options[:strict]
          @queues = queues.map { |q| "queue:#{q}" }
          @unique_queues = @queues.uniq
        end

        protected

        def prioritized_queues(base_queues)
          queues = []
          priorities = Sidekiq::Priority.priorities
          priorities.each do |priority|
            base_queues.each do |queue|
              queues << Sidekiq::Priority.queue_with_priority(queue, priority)
            end
          end
          queues
        end
      end
    end
  end
end
