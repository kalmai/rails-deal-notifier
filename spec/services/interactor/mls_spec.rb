# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Interactor::Mls do
  describe '#store_games' do
    subject(:execution) { described_class.store_games }

    before do
      stub_request(:get, %r{#{described_class::BASE_URL}/matches/*})
        .to_return(status: 200, body: file_fixture('mls_raw_data.json').read)
      create(:team, short_name: 'clb')
      create(:team, short_name: 'ne')
      create(:team, short_name: 'van')
      create(:team, short_name: 'lafc')
    end

    it 'stores the games' do
      expect { execution }.to change(Game, :count).by(2)
    end
  end

  describe '#update_games' do
    subject(:execution) { described_class.store_games }

    before do
      stub_request(:get, %r{#{described_class::BASE_URL}/matches/*})
        .to_return(status: 200, body: file_fixture('mls_raw_data.json').read)
      stub_request(:get, %r{#{described_class::GOAL_DATA_URL}/matches/*})
        .to_return(status: 200, body: file_fixture('mls_goal_update_data.json').read)
      # create a factory for the games
      # create(:team, short_name: 'atl')
      # create(:team, short_name: 'mtl')
    end

    it 'updates the games' do
      expect { execution }.to change(Game, :count).by(2)
    end
  end
end
