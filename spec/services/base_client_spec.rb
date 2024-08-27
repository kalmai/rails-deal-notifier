# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BaseClient do
  let(:client) { Class.new { include BaseClient } }

  describe '#results_cache' do
    subject(:invocation) { client.new.results_cache }

    it 'raises an error expecting the client to override the method' do
      expect { invocation }.to raise_error(NotImplementedError)
    end

    context 'when the client implements the method' do
      let(:client) do
        Class.new do
          include BaseClient
          def results_cache = true
        end
      end

      it 'does not raise the error' do
        expect { invocation }.not_to raise_error
      end
    end
  end

  describe '#schedule_cache' do
    subject(:invocation) { client.new.schedule_cache }

    it 'raises an error expecting the client to override the method' do
      expect { invocation }.to raise_error(NotImplementedError)
    end

    context 'when the client implements the method' do
      let(:client) do
        Class.new do
          include BaseClient
          def schedule_cache = true
        end
      end

      it 'does not raise the error' do
        expect { invocation }.not_to raise_error
      end
    end
  end

  describe '#call' do
    subject(:invocation) { client.new.call(method_name) }

    let(:method_name) { 'non_existant_method' }

    it 'raises NotImplementedErr' do
      expect { invocation }.to raise_error(NoMethodError)
    end

    context 'when the method exists' do
      let(:client) do
        Class.new do
          include BaseClient

          private

          def existing_method = true
        end
      end
      let(:method_name) { 'existing_method' }

      it 'does not raise the error' do
        expect { invocation }.not_to raise_error
      end
    end
  end
end
