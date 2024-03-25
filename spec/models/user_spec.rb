# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  describe 'validations' do
    it { is_expected.to validate_presence_of :postal }
    it { is_expected.to validate_presence_of :region }
    it { is_expected.to validate_presence_of :country }
    it { is_expected.to validate_presence_of :timezone }
  end

  describe 'associations' do
    it { is_expected.to have_many :contact_methods }
    it { is_expected.to have_many(:promotions).through :subscriptions }
  end

  describe '#populate_default_promotions' do
    context 'when there are multiple promotions in different regions' do
      let(:region) { 'ohio' }

      before do
        create(:team, :with_promotions, region:, promotion_count: 1)
        create(:team, :with_promotions)
      end

      it 'adds promotions based on region to the user' do
        ohioan = build(:user, region:)
        expect do
          ohioan.save!
          ohioan.reload
        end.to change { ohioan.subscriptions.count }.by(1)
      end
    end
  end
end
