require 'spec_helper'
require 'sidekiq/priority/server/fetch'

describe Sidekiq::Priority::Server do
  describe '#initialize' do
    context 'when sidekiq pro is installed' do

      before(:all) do
        module Sidekiq
          module Pro
            class ReliableFetch
              class Strict
              end
              class Weighted
              end
            end
          end
        end
      end

      let(:fetch) { Sidekiq::Priority::Server.reliable_priority_fetch_class.new(queues: %w(foo bar), strict: true, index: 1)}

      it 'should use the reliable priority fetch class' do
        expect(Sidekiq::Priority::Server.priority_fetch_class).to eq(Sidekiq::Priority::Server::ReliableFetch)
      end

      it 'sets unique queues' do
        require 'socket'
        expected_list = [
            'queue:foo_high',
            'queue:bar_high',
            'queue:foo',
            'queue:bar',
            'queue:foo_low',
            'queue:bar_low'
        ].map{ |queue| [queue, "#{queue}_#{Socket.gethostname}_1"] }

        expect(fetch.instance_variable_get(:@queues)).to eq(expected_list)
      end

      it 'sets the algorithm variable' do
        expect(fetch.instance_variable_get(:@algo)).to eq(Sidekiq::Pro::ReliableFetch::Strict)
      end

      it 'sets the internal variable' do
        expect(fetch.instance_variable_get(:@internal)).to eq([])
      end

      context 'and redundant queues are specified' do

        let(:fetch) { Sidekiq::Priority::Server.reliable_priority_fetch_class.new(queues: %w(foo bar foo), strict: true, index: 1)}

        it 'sets queues' do
          require 'socket'
          expected_list = [
              'queue:foo_high',
              'queue:bar_high',
              'queue:foo_high',
              'queue:foo',
              'queue:bar',
              'queue:foo',
              'queue:foo_low',
              'queue:bar_low',
              'queue:foo_low'
          ].map{ |queue| [queue, "#{queue}_#{Socket.gethostname}_1"] }

          expect(fetch.instance_variable_get(:@queues)).to eq(expected_list)
        end

        it 'sets the algorithm variable' do
          expect(fetch.instance_variable_get(:@algo)).to eq(Sidekiq::Pro::ReliableFetch::Weighted)
        end

        it 'sets the internal variable' do
          expect(fetch.instance_variable_get(:@internal)).to eq([])
        end
      end
    end
  end
end