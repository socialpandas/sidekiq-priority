require 'celluloid'
require 'sidekiq/fetch'

module Sidekiq
  module Priority
    module Server

      def self.configure_priority_fetch
        Sidekiq.configure_server do |config|
          Sidekiq.options[:fetch] = Sidekiq::Priority::Server.priority_fetch_class
        end
      end

      def self.priority_fetch_class
        if defined? Sidekiq::Pro::ReliableFetch
          reliable_priority_fetch_class
        else
          basic_priority_fetch_class
        end
      end

      def self.reliable_priority_fetch_class
        return Sidekiq::Priority::Server::ReliableFetch if defined?(Sidekiq::Priority::Server::ReliableFetch)

        Sidekiq::Priority::Server.const_set('ReliableFetch', Class.new(Sidekiq::Pro::ReliableFetch) do
          def initialize(options)
            @queues = prioritized_queues(options[:queues]).map {|q| ["queue:#{q}", "queue:#{q}_#{Socket.gethostname}_#{options[:index]}"] }
            @algo = (@queues.length == @queues.uniq.length ? Sidekiq::Pro::ReliableFetch::Strict : Sidekiq::Pro::ReliableFetch::Weighted)
            @internal = Sidekiq.redis do |conn|
              bulk_reply = conn.pipelined do
                @queues.each do |(_, working_queue)|
                  conn.lrange(working_queue, 0, -1)
                end
              end
              memo = []
              bulk_reply.each_with_index do |vals, i|
                queue = @queues[i][0]
                working_queue = @queues[i][1]
                memo.unshift(*vals.map do |msg|
                  [queue, working_queue, msg]
                end)
              end
              memo
            end
            Sidekiq.logger.warn("ReliableFetch: recovering work on #{@internal.size} messages") if @internal.size > 0
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
        )
      end

      def self.basic_priority_fetch_class
        Sidekiq::Priority::Server.const_set('BasicFetch', Class.new(Sidekiq::BasicFetch) do

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
        )
      end
    end
  end
end
