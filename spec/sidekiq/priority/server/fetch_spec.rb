require 'spec_helper'

describe Sidekiq::Priority::Server::Fetch do
  describe '#initialize' do
    before :all do
      options = {
        queues: ['foo', 'bar', 'foo'],
        strict: true
      }
      @fetch = Sidekiq::Priority::Server::Fetch.new(options)
    end

    it 'sets queues' do
      @fetch.instance_variable_get(:@queues).should == [
        'queue:foo_high',
        'queue:bar_high',
        'queue:foo_high',
        'queue:foo',
        'queue:bar',
        'queue:foo',
        'queue:foo_low',
        'queue:bar_low',
        'queue:foo_low'
      ]
    end

    it 'sets unique_queues' do
      @fetch.instance_variable_get(:@unique_queues).should == [
        'queue:foo_high',
        'queue:bar_high',
        'queue:foo',
        'queue:bar',
        'queue:foo_low',
        'queue:bar_low'
      ]
    end
  end
end
