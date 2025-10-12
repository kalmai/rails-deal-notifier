# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Evaluator::Client do
  subject(:evaluation) { described_class.new(promotion:, game:).evaluate(api_methods) }

  let!(:promotion) { create(:promotion, :with_users, api_parameters:, api_methods:) }
  let!(:game) { create(:game, home_team: promotion.team, finalized:) }

  let(:api_methods) { %i[played?].concat(additional_methods) }
  let(:api_parameters) { {} }
  let(:additional_methods) { [] }
  let(:finalized) { true }

  describe '#played?' do
    it { is_expected.to be true }

    context 'when finalized is false' do
      let(:finalized) { false }

      it { is_expected.to be false }
    end
  end

  describe '#scored_in?' do
    let(:api_parameters) { { period: } }
    let(:additional_methods) { ['scored_in?'] }
    let(:period) { 1 }

    it { is_expected.to be false }

    context 'when there are goals scored in the games' do
      before do
        create(:event, game:, team: game.home_team)
        create(:event, game:, team: game.away_team)
      end

      it { is_expected.to be true }

      context 'when there is no goal in the provided period' do
        let(:period) { 50 }

        it { is_expected.to be false }
      end
    end
  end

  describe '#first_goal' do
    let(:additional_methods) { ['first_goal?'] }
    let(:home_utc_occurred_at) { Time.zone.now - 10.minutes }
    let(:away_utc_occurred_at) { Time.zone.now - 5.minutes }

    it { is_expected.to be false }

    context 'when there are goals in the game' do
      before do
        create(:event, game:, team: game.home_team, utc_occurred_at: home_utc_occurred_at)
        create(:event, game:, team: game.away_team, utc_occurred_at: away_utc_occurred_at)
      end

      it { is_expected.to be true }

      context 'when the opponents first goal is first' do
        let(:away_utc_occurred_at) { Time.zone.now - 100.minutes }

        it { is_expected.to be false }
      end
    end
  end

  describe '#perfect_defence?' do
    let(:additional_methods) { ['perfect_defence?'] }

    it { is_expected.to be true }

    context 'when the opponent has scored' do
      before { create(:event, game:, team: game.away_team) }

      it { is_expected.to be false }
    end
  end

  describe '#goal_count_equal_or_above?' do
    let(:additional_methods) { ['goal_count_equal_or_above?'] }
    let(:api_parameters) { { goals_count: 2 } }
    let(:goal_count) { 2 }

    it { is_expected.to be false }

    context 'when there are goals for the team' do
      before do
        create_list(:event, goal_count, game:, team: game.home_team)
      end

      it { is_expected.to be true }

      context 'when the scored goals exceed the required goals' do
        let(:api_parameters) { { goals_count: 1 } }

        it { is_expected.to be true }
      end

      context 'when the scored goals are below the threshold' do
        let(:api_parameters) { { goals_count: 68 } }

        it { is_expected.to be false }
      end
    end
  end

  describe '#home?' do
    let(:api_methods) { ['home?'] }

    it { is_expected.to be true }

    context 'when they are away' do
      let(:game) { create(:game, away_team: promotion.team, finalized:) }

      it { is_expected.to be false }
    end
  end

  describe '#away?' do
    let(:api_methods) { ['away?'] }

    it { is_expected.to be false }

    context 'when they are home' do
      let(:game) { create(:game, home_team: promotion.team, finalized:) }

      it { is_expected.to be false }
    end
  end

  describe '#won?' do
    let(:api_methods) { ['won?'] }

    it { is_expected.to be false }

    context 'when it is a tie' do
      let(:home_goal_count) { 1 }
      let(:away_goal_count) { 1 }

      before do
        create_list(:event, home_goal_count, game:, team: game.home_team)
        create_list(:event, away_goal_count, game:, team: game.away_team)
      end

      it { is_expected.to be false }

      context 'when the home team has scored more goals' do
        let(:home_goal_count) { 10 }

        it { is_expected.to be true }
      end

      context 'when the away team has scored more goals' do
        let(:away_goal_count) { 10 }

        it { is_expected.to be false }
      end
    end
  end
end
