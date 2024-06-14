# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Promotion do
  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
  let(:cache) { Rails.cache }

  before do
    allow(Rails).to receive(:cache).and_return(memory_store)
  end

  after do
    Rails.cache.clear
  end

  it { is_expected.to belong_to(:team).class_name('Team') }
  it { is_expected.to validate_presence_of(:company) }

  it { is_expected.to have_many(:users).through(:subscriptions) }

  describe '#utc_notification_time' do
    subject(:notification_time) { promotion.utc_notification_time }

    let(:promotion) { create(:promotion, :cbj_moo_moo_carwash) }
    let(:today_games) do
      [BaseClient::TodayGame.new(away?: false, team_abbrev: promotion.team.short_name, utc_start_time:)]
    end
    let(:utc_start_time) { Time.zone.now }

    before do
      Rails.cache.write("#{promotion.team.league.short_name.titleize}_today", today_games)
    end

    it { is_expected.to eq utc_start_time }
  end

  describe '#evaluate' do
    subject(:notification_time) { promotion.evaluate }

    let(:promotion) { create(:promotion, :cbj_moo_moo_carwash, api_methods:) }
    let(:api_methods) { ['scored_in?'] }
    let(:yesterday_games) do
      { 'cbj' => BaseClient::GameResult.new(won?: won, goals: cbj_goals, away?: false, opponent: 'OTT') }
    end
    let(:cbj_goals) { [BaseClient::Goal.new(period: 1, time: '00:15'), BaseClient::Goal.new(period: 3, time: '05:21')] }
    let(:won) { false }

    before do
      Rails.cache.write("#{promotion.team.league.short_name.titleize}_yesterday", yesterday_games)
    end

    it { is_expected.to be true }

    context 'when they did not score in the period' do
      let(:cbj_goals) { [BaseClient::Goal.new(period: 1, time: '00:15')] }

      it { is_expected.to be false }

      context 'with no goals' do
        let(:cbj_goals) { [] }

        it { is_expected.to be false }
      end
    end

    context 'when they did not play yesterday' do
      let(:yesterday_games) { {} }

      it { is_expected.to be false }
    end

    describe '#won?' do
      let(:api_methods) { ['won?'] }

      it { is_expected.to be false }

      context 'when they won' do
        let(:won) { true }

        it { is_expected.to be true }
      end

      context 'when they did not play yesterday' do
        let(:yesterday_games) { {} }

        it { is_expected.to be false }
      end
    end

    describe '#first_goal?' do
      let(:api_methods) { ['first_goal?'] }
      let(:yesterday_games) do
        {
          'cbj' => BaseClient::GameResult.new(won?: true, goals: cbj_goals, away?: false, opponent: 'OTT'),
          'ott' => BaseClient::GameResult.new(won?: false, goals: ott_goals, away?: true, opponent: 'CBJ')
        }
      end
      let(:cbj_goals) do
        [BaseClient::Goal.new(period: 1, time: '00:15'), BaseClient::Goal.new(period: 3, time: '05:21')]
      end
      let(:ott_goals) { [BaseClient::Goal.new(period: 3, time: '07:25')] }

      before { Rails.cache.write("#{promotion.team.league.short_name.titleize}_yesterday", yesterday_games) }

      it { is_expected.to be true }

      context 'when the defenders have no goals' do
        let(:cbj_goals) { [] }

        it { is_expected.to be false }

        context 'when both teams have no goals' do
          let(:ott_goals) { [] }

          it { is_expected.to be false }
        end
      end

      context 'when both teams score in the same period' do
        let(:ott_goals) { [BaseClient::Goal.new(period: 1, time: '01:09')] }

        it { is_expected.to be true }
      end
    end
  end
end
