# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Interactor::UpdateGamesJob do
  subject(:job) { described_class.new }

  let(:freeze_time) { Time.parse('2024-10-02T10:00:00.0000000Z') }

  before { travel_to(freeze_time) }

  after { travel_back }

  describe '#perform' do
    let!(:game) { create(:game) }

    before do
      stub_request(:get, %r{#{Interactor::Mls::BASE_URL}/*})
        .to_return(status: 200, body: file_fixture('mls/raw_update_data.json').read)
    end

    it 'performs the job successfully' do
      expect do
        job.perform_now
        game.reload
      end
        .to change(game, :finalized).from(false).to(true)
        .and change { game.events.count }.from(0).to(5)
        .and change { game.home_goals.count }.from(0).to(1)
        .and change { game.away_goals.count }.from(0).to(4)
    end

    context 'when the league is out of season' do
      let(:interactor) { Interactor::Mls }

      before do
        allow(Interactor::Mls).to receive(:new).and_return(interactor)
        allow(interactor).to receive(:update_games)
      end

      it 'does not trigger the interactor' do
        expect(interactor).not_to have_received(:update_games)
      end
    end

    context 'when the game is updated multiple times with the same data' do
      let(:modified_update_data) do
        data = JSON.parse(file_fixture('mls/raw_update_data.json').read)
        data['match_info']['data_status'] = 'not_finalized'
        data.to_json
      end

      before do
        stub_request(:get, %r{#{Interactor::Mls::BASE_URL}/*})
          .to_return(status: 200, body: modified_update_data)
      end

      it 'does not update the data' do
        expect do
          described_class.new.perform_now
          described_class.new.perform_now
          described_class.new.perform_now
          described_class.new.perform_now
          game.reload
        end
          .to change { game.events.count }.from(0).to(5)
          .and change { game.home_goals.count }.from(0).to(1)
          .and change { game.away_goals.count }.from(0).to(4)
      end
    end
  end
end
