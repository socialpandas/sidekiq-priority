module Sidekiq
  module Superworker
    class SubjobProcessor
      class << self
        alias_method :original_sidekiq_item, :sidekiq_item

        def sidekiq_item(subjob, klass, jid)
          item = original_sidekiq_item(subjob, klass, jid)

          # Modify the queue to be the prioritized queue, if necessary
          priority = subjob.meta ? subjob.meta[:priority] : nil
          if priority
            queue = klass.get_sidekiq_options['queue']
            queue = Sidekiq::Priority.queue_with_priority(queue, priority)
            item['queue'] = queue
          end
          item
        end
      end
    end
  end
end
