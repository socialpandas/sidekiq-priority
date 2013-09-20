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
      priority.nil? ? queue : "#{queue}_#{priority}"
    end
  end
end

Sidekiq.configure_server do |config|
  require "#{directory}/priority/server/fetch.rb"
  Sidekiq.options[:fetch] = Sidekiq::Priority::Server::Fetch
end
