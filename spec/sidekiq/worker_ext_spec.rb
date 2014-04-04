require 'spec_helper'

describe Sidekiq::Worker do
  describe '.perform_with_priority' do
    before :all do
      class TestWorker
        include Sidekiq::Worker

        sidekiq_options :queue => :foo

        def perform(first, second)
        end
      end
    end

    it 'sends an item to client_push' do
      TestWorker.stub(:client_push) { |item| item }
      item = TestWorker.perform_with_priority(:high, 1, 2)
      item.should == {
        'class' => TestWorker,
        'args' => [1, 2],
        'queue' => 'foo_high'
      }
    end

    it 'sends an item to the default queue if priority is nil' do
      TestWorker.stub(:client_push) { |item| item }
      item = TestWorker.perform_with_priority(:invalid_priority, 1, 2)
      item.should == {
          'class' => TestWorker,
          'args' => [1, 2],
          'queue' => :foo
      }
    end

    it 'sends an item to the default queue if a random priority is given' do
      TestWorker.stub(:client_push) { |item| item }
      item = TestWorker.perform_with_priority(:random_priority, 1, 2)
      item.should == {
          'class' => TestWorker,
          'args' => [1, 2],
          'queue' => :foo
      }
    end

  end
end
