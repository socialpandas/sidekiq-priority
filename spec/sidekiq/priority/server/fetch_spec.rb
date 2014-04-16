require 'spec_helper'
require 'sidekiq/priority/server/fetch'

describe Sidekiq::Priority::Server do
  describe '#initialize' do

    context 'when sidekiq pro is not installed' do

      before(:all) do
        if defined? Sidekiq::Pro::ReliableFetch
          Sidekiq::Pro.send(:remove_const, :ReliableFetch)
        end
      end

      it 'should use the basic priority fetch class' do
        expect(Sidekiq::Priority::Server.priority_fetch_class).to eq(Sidekiq::Priority::Server::BasicFetch)
      end

      let(:fetch) { Sidekiq::Priority::Server.basic_priority_fetch_class.new(queues: %w(foo bar foo), strict: true, index: 1) }

      it 'sets queues' do
        expect(fetch.instance_variable_get(:@queues)).to eq([
            'queue:foo_high',
            'queue:bar_high',
            'queue:foo_high',
            'queue:foo',
            'queue:bar',
            'queue:foo',
            'queue:foo_low',
            'queue:bar_low',
            'queue:foo_low'
        ])
      end

      it 'sets unique_queues' do
        expect(fetch.instance_variable_get(:@unique_queues)).to eq([
            'queue:foo_high',
            'queue:bar_high',
            'queue:foo',
            'queue:bar',
            'queue:foo_low',
            'queue:bar_low'
        ])
      end
    end
  end
end
