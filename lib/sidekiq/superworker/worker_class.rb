module Sidekiq
  module Superworker
    class WorkerClass
      class << self
        def perform_with_priority(priority, *arg_values)
          options = initialize_superjob(arg_values)
          options[:meta] ||= {}
          options[:meta].merge!({ priority: priority })
          subjobs = create_subjobs(arg_values, options)
          SuperjobProcessor.create(@superjob_id, @class_name, arg_values, subjobs, options)
        end
      end
    end
  end
end
