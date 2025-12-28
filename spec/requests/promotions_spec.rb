# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Promotions' do
  let(:new_york_ip) { '63.116.61.253' }
  let(:postal_code) { '10001' }
  let(:new_york_info) do
    {
      'coordinates' => [40.7143528, -74.0059731],
      'address' => 'New York, NY, USA',
      'state' => 'New York',
      'state_code' => 'NY',
      'country' => 'United States',
      'country_code' => 'US'
    }
  end

  before do
    Geocoder.configure(lookup: :test, ip_lookup: :test)
    Geocoder::Lookup::Test.add_stub(new_york_ip, [new_york_info])
    Geocoder::Lookup::Test.add_stub(
      postal_code, [
        { 'properties' => new_york_info.merge({ 'timezone' => { 'name' => 'America/New_York' } }) }
      ]
    )
  end

  describe '#show' do
    it 'returns no promotions' do
      get "/promotions/#{postal_code}", headers: { 'REMOTE_ADDR' => new_york_ip }

      # when a stream is rendered it prepends `promotion_` and the id of the object
      # meaning when we see/don't see it there are promotions rendered or not
      expect(response.body).not_to include('promotion_')
    end

    context 'when promtions are registered to the region' do
      let(:promotions) { create_list(:promotion, 2, team: create(:team, region: 'ny')) }

      before { promotions }

      it 'returns promotions for the passed in zipcode' do
        get "/promotions/#{postal_code}", headers: { 'REMOTE_ADDR' => new_york_ip }

        expect(response.body).to include("promotion_#{promotions.first.id}", "promotion_#{promotions.last.id}")
      end
    end
  end
end
