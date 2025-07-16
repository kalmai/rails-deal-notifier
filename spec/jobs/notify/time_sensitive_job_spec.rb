# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notify::TimeSensitiveJob do
  let!(:promotion) { create(:promotion, :with_users, team:, timing_methods:, timing_parameters:) }
  let!(:team) { create(:team, region: 'ny') }
  let(:timing_methods) { [] }
  let(:timing_parameters) { { minutes_before: 60 } }
  let(:user) { promotion.users.first }
  let(:timezone) { 'America/New_York' }
  let(:freeze_time) { Time.parse('2024-10-02T10:00:00.0000000Z') }
  let(:utc_start_time) { Time.parse('2024-10-02T23:30:00.0000000Z') }
  let(:next_game) { build(:game, home_team: team, finalized: false, utc_start_time:) }

  before do
    Timecop.freeze(freeze_time)
    next_game.save!
  end

  after { Timecop.return }

  describe '#perform' do
    it 'enqueues the email' do
      expect { described_class.new.perform }.to have_enqueued_mail(TimeSensitiveMailer, :notify)
        .with(params: { user:, promotion: }, args: [])
        .on_queue(:default).at(utc_start_time - 1.hour).exactly(:once)
    end

    context 'when there are location requirements for the promotion' do
      let(:timing_methods) { ['home?'] }

      it 'enqueues the email' do
        expect { described_class.new.perform }.to have_enqueued_mail(TimeSensitiveMailer, :notify)
          .with(params: { user:, promotion: }, args: [])
          .on_queue(:default).at(utc_start_time - 1.hour).exactly(:once)
      end

      context 'when the it does not fulfill the location requirements' do
        let(:team_abbr) { 'arz' }
        let(:next_game) { build(:game, away_team: team, finalized: false, utc_start_time:) }

        it 'does not enque the email' do
          expect { described_class.new.perform }.not_to have_enqueued_mail(TimeSensitiveMailer, :notify)
        end
      end
    end
  end
end
