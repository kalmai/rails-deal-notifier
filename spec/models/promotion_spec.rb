# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Promotion do
  let(:promotion) do
    create(:promotion, :with_users, api_methods: ['scored_in?'], api_parameters: { period: 1 })
  end
  let!(:game) { create(:game, home_team: promotion.team, finalized: true) }
  let(:freeze_time) { game.utc_start_time }

  before { Timecop.freeze(freeze_time) }
  after { Timecop.return }

  it { is_expected.to belong_to(:team).class_name('Team') }
  it { is_expected.to validate_presence_of(:company) }

  it { is_expected.to have_many(:users).through(:subscriptions) }

  describe '#evaluate' do
    subject(:evaluation) { promotion.evaluate_most_recent_game }

    it { is_expected.to be false }

    context 'when there is event data' do
      before do
        create(:event, game:, team: game.home_team)
        create(:event, game:, team: game.away_team)
      end

      it { is_expected.to be true }

      context 'when it is past the promotions valid use window' do
        let(:freeze_time) { game.utc_start_time + 72.hours }

        it { is_expected.to be false }
      end
    end
  end

  describe '#most_recent_game' do
    subject(:evaluation) { promotion.most_recent_game }

    it { is_expected.to eq game }
  end

  describe '#next_game' do
    subject(:evaluation) { promotion.next_game }

    let!(:game) { create(:game, home_team: promotion.team, finalized: false) }

    it { is_expected.to eq game }
  end
end
