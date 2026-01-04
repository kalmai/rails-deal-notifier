# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Upsert::Promotions do
  let(:team) { create(:team, promotions:, league:) }
  let(:league) { create(:league, short_name: 'mls') }
  let(:promotions) { create_list(:promotion, existing_promotion_count) }
  let(:existing_promotion_count) { 1 }
  let(:upsert_promotions) { [upserting_promotion] }
  let(:upserting_promotion) { build(:promotion, company: promotions.first.company).attributes }
  let(:upsert_data) { { 'mls' => { team.short_name => upsert_promotions }, 'nhl' => nil } }

  before do
    allow(described_class).to receive(:data).and_return(upsert_data)
  end

  describe '#execute_for' do
    it 'updates the existing promotion in place' do
      expect { described_class.execute_for(team:) }
        .to change(promotions.first, :source_url)
        .and change(Promotion, :count).by(0) # rubocop:disable Rspec/ChangeByZero
    end

    context 'when the company is no longer included in the teams promotions' do
      let(:existing_promotion_count) { 2 }

      it 'removes the promotion' do
        expect { described_class.execute_for(team:) }.to change(Promotion, :count).from(2).to(1)
      end
    end

    context 'when there is a new promotion' do
      let(:existing_promotion_count) { 0 }
      let(:upserting_promotion) { build(:promotion).attributes }

      it 'creates the new promotion' do
        expect { described_class.execute_for(team:) }.to change(Promotion, :count).from(0).to(1)
      end
    end

    context 'when create update and delete happen all at once' do
      let(:existing_promotion_count) { 2 }
      let(:upsert_promotions) { [upserting_promotion, build(:promotion).attributes] }

      it 'creates, updates, and deletes' do
        expect { described_class.execute_for(team:) }
          # check for upsert
          .to change(promotions.first, :source_url)
          # we're deleting -1 and creating +1 and updating +0
          .and change(Promotion, :count).by(0) # rubocop:disable Rspec/ChangeByZero
        # check for delete
        expect { promotions.last.reload }.to raise_error(ActiveRecord::RecordNotFound)
        # check for create
        expect(team.reload.promotions.map(&:company)).to include(upsert_promotions.last['company'])
      end
    end
  end
end
