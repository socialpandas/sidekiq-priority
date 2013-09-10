module Sidekiq
  module Worker
    module ClassMethods
      def perform_with_priority(priority, *args)
        queue = self.get_sidekiq_options['queue']
        queue = Sidekiq::Priority.queue_with_priority(queue, priority)
        client_push('class' => self, 'args' => args, 'queue' => queue)
      end
    end
  end
end
