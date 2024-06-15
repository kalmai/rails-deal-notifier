# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Nhl::Client do
  subject(:evaluation) { client.call(method) }

  let(:client) { described_class.new(args: params) }
  let(:method) { :won? }
  let(:params) { base_params.merge(additional_params) }
  let(:base_params) { { timezone:, short_name: } }
  let(:short_name) { 'cbj' }
  let(:timezone) { 'America/New_York' }
  let(:additional_params) { {} }
  let(:yesterday_start) { Time.current.yesterday }
  let(:won) { true }
  let(:away) { false }
  let(:opponent) { 'OTT' }
  let(:cbj_goals) { [BaseClient::Goal.new(period: 1, time: '00:15'), BaseClient::Goal.new(period: 3, time: '05:21')] }
  let(:ott_goals) { [BaseClient::Goal.new(period: 3, time: '07:25')] }
  let(:utc_start_time) { Time.use_zone(timezone) { Time.current.end_of_day }.utc }
  let(:freeze_time) { Time.use_zone(timezone) { Time.current.change(hour: 18) }.utc }
  let(:schedule_cache) do
    [
      BaseClient::TodayGame.new(away?: true, team_abbrev: 'cbj', utc_start_time:),
      BaseClient::TodayGame.new(away?: false, team_abbrev: 'arz', utc_start_time:)
    ]
  end
  let(:results_cache) do
    {
      'cbj' => BaseClient::GameResult.new(
        won?: true, goals: cbj_goals, away?: false, opponent: 'OTT',
        utc_start_time: yesterday_start
      ),
      'ott' => BaseClient::GameResult.new(
        won?: false, goals: ott_goals, away?: true, opponent: 'CBJ',
        utc_start_time: yesterday_start
      )
    }
  end

  before do
    Timecop.freeze(freeze_time)
    allow(client).to receive_messages(results_cache:, schedule_cache:)
  end

  after do
    Timecop.return
  end

  describe '#call' do
    it { is_expected.to be true }

    context 'when the team did not play yesterday' do
      let(:short_name) { 'arz' }

      it { is_expected.to be false }
    end

    describe '#scored_in?' do
      let(:additional_params) { { period: 3 } }
      let(:method) { 'scored_in?' }

      it { is_expected.to be true }

      context 'when there is no goal in the provided period' do
        let(:additional_params) { { period: 2 } }

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
        let(:cbj_goals) { [BaseClient::Goal.new(period: 3, time: '05:21')] }
        let(:ott_goals) { [BaseClient::Goal.new(period: 3, time: '07:25')] }

        it { is_expected.to be true }
      end

      context 'when the defender has no goals' do
        let(:cbj_goals) { [] }

        it { is_expected.to be false }
      end

      context 'when the defenders first goal is in a later period than the opponent' do
        let(:cbj_goals) { [BaseClient::Goal.new(period: 2, time: '00:15')] }
        let(:ott_goals) { [BaseClient::Goal.new(period: 1, time: '07:25')] }

        it { is_expected.to be false }
      end
    end

    describe '#playing_today_at' do
      let(:method) { 'playing_today_at' }

      it { is_expected.to eq utc_start_time }

      context 'when team is not playing today' do
        let(:short_name) { 'ott' }

        it { is_expected.to be_nil }
      end
    end

    describe '#goal_count_equal_or_above?' do
      let(:method) { 'goal_count_equal_or_above?' }
      let(:additional_params) { { goals_count: 2 } }

      it { is_expected.to be true }

      context 'when the scored goals exceed the required goals' do
        let(:additional_params) { { goals_count: 1 } }

        it { is_expected.to be true }
      end

      context 'when the scored goals are below the threshold' do
        let(:additional_params) { { goals_count: 68 } }

        it { is_expected.to be false }
      end
    end

    describe '#home?' do
      let(:method) { 'home?' }

      it { is_expected.to be true }

      context 'when they are away' do
        let(:short_name) { 'ott' }

        it { is_expected.to be false }
      end
    end

    describe '#away?' do
      let(:method) { 'away?' }

      it { is_expected.to be false }

      context 'when they are away' do
        let(:short_name) { 'ott' }

        it { is_expected.to be true }
      end
    end

    describe '#perfect_defence?' do
      let(:method) { 'perfect_defence?' }

      it { is_expected.to be false }

      context 'when there are no goals on the defending team' do
        let(:ott_goals) { [] }

        it { is_expected.to be true }
      end
    end
  end
end
