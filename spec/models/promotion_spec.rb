# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Promotion do
  let(:promotion) do
    create(:promotion, :with_users, api_methods: ['scored_in?'], api_parameters: { period: 1 })
  end
  let!(:game) { create(:game, home_team: promotion.team, has_consumed_results: true) }

  it { is_expected.to belong_to(:team).class_name('Team') }
  it { is_expected.to validate_presence_of(:company) }

  it { is_expected.to have_many(:users).through(:subscriptions) }

  describe '#evaluate' do
    subject(:evaluation) { promotion.evaluate_most_recent_game }

    before do
      create(:goal, game:, team: game.home_team)
      create(:goal, game:, team: game.away_team)
    end

    it { is_expected.to be true }
  end

  describe '#most_recent_game' do
    subject(:evaluation) { promotion.most_recent_game }

    it { is_expected.to eq game }
  end
end
