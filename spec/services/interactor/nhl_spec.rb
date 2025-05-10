# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Interactor::Nhl do
  describe '#store_games' do
    subject(:execution) { described_class.store_games }

    before do
      stub_request(:get, %r{#{described_class::BASE_URL}/v1/schedule/*})
        .to_return(status: 200, body: file_fixture('nhl/raw_data.json').read)
      %w[tbl car sjs lak].each { |short_name| create(:team, short_name:, league_name: 'nhl') }
    end

    it 'stores the games' do
      expect { execution }.to change(Game, :count).by(2)
    end

    context 'when the game has already been stored' do
      before { create(:game, slug: 'carvstbl-10-11-2024') }

      it 'skips the existing game and continues writing newer games' do
        expect { execution }.to change(Game, :count).by(1)
      end
    end
  end

  describe '#update_games' do
    subject(:execution) { described_class.update_games }

    let(:game) do
      create(
        :game,
        league_short_name: 'nhl', home_short_name: 'car', away_short_name: 'tbl',
        league_specifics: {}, utc_start_time: Time.parse('2024-10-11 23:00:00.000000000 +0000')
      )
    end

    before do
      stub_request(:get, %r{#{described_class::BASE_URL}/v1/score/*})
        .to_return(status: 200, body: file_fixture('nhl/update_data.json').read)
    end

    it 'updates the games' do
      expect do
        execution
        game.reload
      end
        .to change(game, :finalized).from(false).to(true)
        .and change { game.events.count }.from(0).to(5)
        .and change { game.home_goals.count }.from(0).to(1)
        .and change { game.away_goals.count }.from(0).to(4)
    end
  end
end
