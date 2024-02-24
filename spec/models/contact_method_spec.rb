# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContactMethod do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:contact_detail) }
    it { is_expected.to validate_presence_of(:contact_type) }
    it { is_expected.to validate_presence_of(:enabled) }
    it { is_expected.to validate_uniqueness_of(:contact_detail).case_insensitive }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user).class_name('User') }
  end

  describe 'encryption' do
    it { is_expected.to encrypt(:contact_detail).downcase(true) }
  end

  describe '#valid_contact_detail?' do
    subject(:contact_method) { build(:contact_method, contact_detail:, contact_type:) }

    let(:contact_detail) { 'test@gmail.com' }
    let(:contact_type) { :email }

    it { is_expected.to be_valid }

    context 'with an email that is too short' do
      let(:contact_detail) { '1@1' }

      it { is_expected.not_to be_valid }
    end

    context 'with an email that is too long' do
      let(:contact_detail) { "1@#{'a' * 1000}" }

      it { is_expected.not_to be_valid }
    end

    context 'with an email that does not conform to email regex' do
      let(:contact_detail) { '11111aaaaaaemailgmail' }

      it { is_expected.not_to be_valid }
    end

    context 'with an unimplemented contact_type' do
      let(:contact_type) { :phone_number }

      it { is_expected.not_to be_valid }
    end
  end
end
