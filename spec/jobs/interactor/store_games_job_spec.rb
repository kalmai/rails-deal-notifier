# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Interactor::StoreGamesJob do
  subject(:job) { described_class.new }

  let(:end_month) { '11' }
  let(:freeze_time) { Time.parse('2024-10-02T10:00:00.0000000Z') }

  before do
    Timecop.freeze(freeze_time)
    create(:league, end_month:, short_name: 'mls')
    job.perform
  end

  after { Timecop.return }

  describe '#perform' do
    it 'performs the job successfully' do
      expect { job }.not_to raise_error
      # expect(RegistrationMailer).to have_received(:with).with({ user: })
    end

    context 'when the league is out of season' do
      let(:end_month) { '9' }

      before do
        allow(Interactor::Mls).to receive(:new).and_return(Interactor::Mls)
        allow(Interactor::Mls).to receive(:store_games)
      end

      it 'does not trigger the interactor' do
        expect(interactor).not_to have_received(:store_games)
      end
    end
  end
end
