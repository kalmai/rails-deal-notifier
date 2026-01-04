# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Interactor::Mls do
  describe '#store_games' do
    subject(:execution) { described_class.store_games }

    before do
      stub_request(:get, %r{#{described_class::BASE_URL}/*})
        .to_return(status: 200, body: file_fixture('mls/raw_data.json').read)
      league = create(:league, short_name: 'mls')
      %w[atl la nsh por].each { create(:team, short_name: it, league:) }
    end

    it 'stores the games' do
      expect { execution }.to change(Game, :count).by(2)
    end

    context 'when the game has already been stored' do
      before { create(:game, slug: 'atlvsnsh-05-03-2025') }

      it 'skips the existing game and continues writing newer games' do
        expect { execution }.to change(Game, :count).by(1)
      end
    end
  end

  describe '#update_games' do
    subject!(:game) { create(:game) }

    before do
      stub_request(:get, %r{#{described_class::BASE_URL}/*})
        .to_return(status: 200, body: file_fixture('mls/raw_update_data.json').read)
    end

    it 'updates the games' do
      expect do
        described_class.update_games
        game.reload
      end
        .to change(game, :finalized).from(false).to(true)
        .and change { game.events.count }.from(0).to(5)
        .and change { game.home_goals.count }.from(0).to(1)
        .and change { game.away_goals.count }.from(0).to(4)
    end

    context 'when the game has no update yet' do
      before do
        stub_request(:get, %r{#{described_class::BASE_URL}/*}).to_raise(RestClient::ExceptionWithResponse.new)
      end

      it 'does not update the game and rescues' do
        described_class.update_games
        game.reload
        expect(game.finalized).to be false
        expect(game.events.count).to eq(0)
      end
    end
  end
end
