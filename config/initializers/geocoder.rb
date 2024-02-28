Geocoder.configure(
  geoapify: {
    api_key: Rails.application.credentials.geoapify_api_key,
    timeout: 5
  },
  ip_lookup: :ipinfo_io,
  lookup: :geoapify
)
