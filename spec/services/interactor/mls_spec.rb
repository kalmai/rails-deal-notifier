# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Interactor::Mls do
  describe '#store_games' do
    subject(:execution) { described_class.store_games }

    before do
      stub_request(:get, %r{#{described_class::BASE_URL}/*})
        .to_return(status: 200, body: file_fixture('mls/raw_data.json').read)
      create(:team, short_name: 'atl')
      create(:team, short_name: 'la')
      create(:team, short_name: 'nsh')
      create(:team, short_name: 'por')
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
    subject(:execution) { described_class.update_games }

    let(:game) { create(:game) }

    before do
      stub_request(:get, %r{#{described_class::BASE_URL}/*})
        .to_return(status: 200, body: file_fixture('mls/raw_update_data.json').read)
    end

    it 'updates the games' do
      expect do
        execution
        game.reload
      end
        .to change(game, :has_consumed_results).from(false).to(true)
        .and change { game.goals.count }.from(0).to(5)
        .and change { game.home_goals.count }.from(0).to(1)
        .and change { game.away_goals.count }.from(0).to(4)
    end
  end
end
