# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Registration::NotifyJob do
  subject(:job) { described_class.new }

  let(:user) { create(:user, :with_contact_methods) }

  describe '#perform' do
    before do
      allow(ApplicationMailer).to receive_message_chain(:with, :welcome_email, :deliver_later).and_return(true)
      job.perform(user:)
    end

    it 'performs the job successfully' do
      expect { job }.not_to raise_error
      expect(ApplicationMailer).to have_received(:with).with({ user: })
    end
  end
end
