# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Registration::NotifyJob do
  subject(:job) { described_class.new }

  let(:user) { create(:user, :with_contact_methods) }

  describe '#perform' do
    before do
      # TODO: figure out how to fix this cop.
      allow(RegistrationMailer).to receive_message_chain(:with, :welcome_email, :deliver_later).and_return(true) # rubocop:disable Rspec/MessageChain
      job.perform(user:)
    end

    it 'performs the job successfully' do
      expect { job }.not_to raise_error
      expect(RegistrationMailer).to have_received(:with).with({ user: })
    end
  end
end
