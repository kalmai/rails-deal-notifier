# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notify::ActionablePromotionJob do
  let(:game) { create(:game, finalized: true, utc_start_time: Time.current.yesterday.change(hour: 16)) }
  let(:promotions) { [create(:promotion, :with_users, user_region: game.home_team.region, team: game.home_team)] }
  let(:user) { promotions.first.users.first }
  let(:time_adjustments) { { hour: 5 } }

  before do
    create(:event, game:, team: game.home_team)
    travel_to(Time.current.in_time_zone(user.timezone).change(time_adjustments))
  end

  after { travel_back }

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

    context 'when the hour is too early' do
      let(:time_adjustments) { { hour: 2 } }

      it 'does not notify the users yet' do
        expect { described_class.new.perform }.not_to have_enqueued_mail(ActionablePromotionMailer, :notify)
      end
    end
  end
end
