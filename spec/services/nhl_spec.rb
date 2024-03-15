# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Nhl::Client do
  subject(:evaluation) { described_class.call(method, params) }

  let(:method) { 'won?' }
  let(:params) { base_params.merge(addional_params) }
  let(:base_params) { { short_name: 'cbj' } }
  let(:addional_params) { {} }
  let(:game_results) do
    {
      'cbj' => GameResult.new(won?: true, goals: cbj_goals, away?: false, opponent: 'OTT'),
      'ott' => GameResult.new(won?: false, goals: ott_goals, away?: true, opponent: 'CBJ')
    }
  end
  let(:won) { true }
  let(:away) { false }
  let(:opponent) { 'OTT' }
  let(:cbj_goals) { [Goal.new(period: 1, time: '00:15'), Goal.new(period: 3, time: '05:21')] }
  let(:ott_goals) { [Goal.new(period: 3, time: '07:25')] }

  before do
    allow(described_class).to receive(:results_for_yesterday).and_return(game_results)
  end

  describe '#call' do
    it { is_expected.to be true }

    context 'when the team did not play yesterday' do
      let(:base_params) { { short_name: 'arz' } }

      it { is_expected.to be false }
    end

    describe '#scored_in?' do
      let(:addional_params) { { period: 3 } }
      let(:method) { 'scored_in?' }

      it { is_expected.to be true }

      context 'when there is no goal in the provided period' do
        let(:addional_params) { { period: 2 } }

        it { is_expected.to be false }
      end

      context 'when there were no goals' do
        let(:cbj_goals) { [] }

        it { is_expected.to be false }
      end
    end

    describe '#first_goal' do
      let(:method) { 'first_goal?' }

      it { is_expected.to be true }

      context 'when both teams score in the same period' do
        let(:cbj_goals) { [Goal.new(period: 3, time: '05:21')] }
        let(:ott_goals) { [Goal.new(period: 3, time: '07:25')] }

        it { is_expected.to be true }
      end

      context 'when the defender has no goals' do
        let(:cbj_goals) { [] }

        it { is_expected.to be false }
      end

      context 'when the defenders first goal is in a later period than the opponent' do
        let(:cbj_goals) { [Goal.new(period: 2, time: '00:15')] }
        let(:ott_goals) { [Goal.new(period: 1, time: '07:25')] }

        it { is_expected.to be false }
      end
    end
  end
end
