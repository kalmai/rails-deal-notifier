# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotifyActionablePromotionJob do
  let(:promotions) { [create(:promotion, :with_league_team_and_users, team_abbr: 'clb')] }
  let(:user) { promotions.first.users.first }
  let(:freeze_time) { Time.current.in_time_zone(user.timezone).change(time_adjustments) }
  let(:time_adjustments) { { hour: 5 } }
  let(:client) { Mls::Client.new(args: { timezone: user.timezone, short_name: promotions.first.team.short_name }) }
  let(:jam_goals) { [BaseClient::Goal.new(period: 3, time: '07:25')] }
  let(:yesterday_start) { Time.current.yesterday }
  let(:clb_goals) do
    [
      BaseClient::Goal.new(period: 1, time: '00:15'),
      BaseClient::Goal.new(period: 3, time: '05:21')
    ]
  end
  let(:results_cache) do
    {
      'clb' => BaseClient::GameResult.new(
        won?: true, goals: clb_goals, away?: false, opponent: 'JAM',
        utc_start_time: yesterday_start
      ),
      'jam' => BaseClient::GameResult.new(
        won?: false, goals: jam_goals, away?: true, opponent: 'CLB',
        utc_start_time: yesterday_start
      )
    }
  end

  before do
    Timecop.freeze(freeze_time)
    allow(Mls::Client).to receive(:new).and_return(client)
    allow(client).to receive(:results_cache).and_return(results_cache)
  end

  after do
    Timecop.return
  end

  describe '#perform' do
    it 'enqueues the email with all the actionable promotions' do
      expect { described_class.new.perform }.to have_enqueued_mail(ActionablePromotionMailer, :notify)
        .with(params: { user:, promotions: }, args: []).on_queue(:default)
        .at(Time.use_zone(user.timezone) { Time.current.at_beginning_of_day + 6.hours }).exactly(:once)
    end

    context 'when the job is kicked off a few minutes late' do
      let(:time_adjustments) { { hour: 5, minutes: 3 } }

      it 'notifies the user at 6am' do
        expect { described_class.new.perform }.to have_enqueued_mail(ActionablePromotionMailer, :notify)
          .with(params: { user:, promotions: }, args: []).on_queue(:default)
          .at(Time.use_zone(user.timezone) { Time.current.at_beginning_of_day + 6.hours }).exactly(:once)
      end
    end

    context 'when the hour too early' do
      let(:time_adjustments) { { hour: 2 } }

      it 'does not notify the users yet' do
        expect { described_class.new.perform }.not_to have_enqueued_mail(ActionablePromotionMailer, :notify)
      end
    end
  end
end
