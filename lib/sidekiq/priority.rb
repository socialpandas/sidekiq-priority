require 'sidekiq'

directory = File.dirname(File.absolute_path(__FILE__))
Dir.glob("#{directory}/priority/*.rb") { |file| require file }
Dir.glob("#{directory}/superworker/**/*.rb") { |file| require file } if defined?(Sidekiq::Superworker)
require "#{directory}/worker_ext.rb"

module Sidekiq
  module Priority
    PRIORITIES = [:high, nil, :low]

    def self.priorities
      @priorities ||= PRIORITIES.dup
    end

    def self.priorities=(priorities)
      @priorities = priorities
    end

    def self.queue_with_priority(queue, priority)
      priority && self.priorities.include?(priority) ? "#{queue}_#{priority}" : queue
    end
  end
end

if defined? Rails
  class ConfigureServer < Rails::Railtie
    config.after_initialize do
      require "#{File.dirname(File.absolute_path(__FILE__))}/priority/server/fetch.rb"
      Sidekiq::Priority::Server.configure_priority_fetch
    end
  end
else
  require "#{directory}/priority/server/fetch.rb"
  Sidekiq::Priority::Server.configure_priority_fetch
end