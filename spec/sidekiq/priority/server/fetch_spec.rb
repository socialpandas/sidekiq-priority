require 'spec_helper'
require 'sidekiq/priority/server/fetch'

describe Sidekiq::Priority::Server::Fetch do
  describe '#initialize' do
    subject { Sidekiq::Priority::Server::Fetch.new(options) }

    let(:options) { { queues: %w(foo bar foo), strict: true } }

    let(:qs) do
      %w(
        queue:foo_high
        queue:bar_high
        queue:foo_high
        queue:foo
        queue:bar
        queue:foo
        queue:foo_low
        queue:bar_low
        queue:foo_low
      )
    end

    let(:uqs) do
      %w(
        queue:foo_high
        queue:bar_high
        queue:foo
        queue:bar
        queue:foo_low
        queue:bar_low
      )
    end

    it 'sets queues' do
      expect(subject.instance_variable_get(:@queues)).to match_array(qs)
    end

    it 'sets unique_queues' do
      expect(subject.instance_variable_get(:@unique_queues)).to match_array(uqs)
    end
  end
end
