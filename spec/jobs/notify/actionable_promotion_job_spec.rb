# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notify::ActionablePromotionJob do
  let(:promotions) { [create(:promotion, :with_users, team:)] }
  let!(:team) { create(:team, region: 'ny') }
  let(:user) { promotions.first.users.first }
  let(:freeze_time) { Time.current.in_time_zone(user.timezone).change(time_adjustments) }
  let(:time_adjustments) { { hour: 5 } }
  let(:game) { create(:game, home_team: team, finalized: true) }

  before do
    create(:event, game:, team:)
    travel_to(freeze_time)
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

    context 'when the hour too early' do
      let(:time_adjustments) { { hour: 2 } }

      it 'does not notify the users yet' do
        expect { described_class.new.perform }.not_to have_enqueued_mail(ActionablePromotionMailer, :notify)
      end
    end
  end
end
