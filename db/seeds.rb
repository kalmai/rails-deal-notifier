# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

unless League.find_by(short_name: 'nhl')
  League.create!(full_name: 'national hockey league', short_name: 'nhl', start_month: 9, end_month: '7+') # October 10, 2023 – June 2024
end
# League.create!(full_name: 'national football league', short_name: 'nfl', start_month: 8, end_month: '2+') # September 5, 2024 – January 5, 2025
# League.create!(full_name: 'major league baseball', short_name: 'mlb', start_month: 4, end_month: '10') # March 20 – September 29, 2024
# League.create!(full_name: 'national basketball association', short_name: 'nba', start_month: 9, end_month: '5+') # October to April
unless League.find_by(short_name: 'mls')
  League.create!(full_name: 'major league soccer', short_name: 'mls', start_month: 2, end_month: '11') # late March/early April to late September/early October
end
# League.create!(full_name: 'canadian football league', short_name: 'cfl', start_month: 5, end_month: '11') # June 6 – October 26, 2024

Wikipedia.seed_teams

### Ohio Soccer Team Start
Promotion.create!(
  company: 'Moo Moo Express Car Wash',
  name: 'Moo Moo Express Clean Sheets = Clean Car',
  promo_type: 'free_gifts',
  promo_code: nil,
  source_url: 'https://www.columbuscrew.com/supporters/promotions',
  redemption_limiter: 'monthly',
  redemption_count: 0,
  hours_valid: 48,
  timing_methods: ['home?'],
  timing_parameters: { minutes_before: 60 },
  api_methods: %w[home? perfect_defence?],
  api_parameters: {},
  team: Team.find_by(short_name: 'clb', region: 'oh', league: League.find_by(short_name: 'mls'))
)
Promotion.create!(
  company: 'Donatos',
  name: 'Donatos - Victory Pizza',
  promo_type: 'order_discounts',
  promo_code: 'CREW',
  source_url: 'https://www.columbuscrew.com/supporters/promotions',
  redemption_limiter: 0,
  redemption_count: 0,
  hours_valid: 24,
  timing_methods: [],
  timing_parameters: {},
  api_methods: ['won?'],
  api_parameters: {},
  team: Team.find_by(short_name: 'clb', region: 'oh', league: League.find_by(short_name: 'mls'))
)
Promotion.create!(
  company: 'Tim Hortons',
  name: 'Tim Hortons - Free Coffee',
  promo_type: 'free_gifts',
  promo_code: nil,
  source_url: 'https://www.columbuscrew.com/supporters/promotions',
  redemption_limiter: 0,
  redemption_count: 0,
  hours_valid: 24,
  timing_methods: [],
  timing_parameters: {},
  api_methods: %w[home? goal_count_equal_or_above?],
  api_parameters: { goals_count: 1 },
  team: Team.find_by(short_name: 'clb', region: 'oh', league: League.find_by(short_name: 'mls'))
)
### Ohio Soccer Team End

### Ohio Hockey Team Start
Promotion.create!(
  company: 'Moo Moo Express Car Wash',
  name: 'Moo Moo Express Car Wash 3rd Period Goal',
  promo_type: 'free_gifts',
  promo_code: nil,
  source_url: 'https://www.nhl.com/bluejackets/fans/gameday-central',
  redemption_limiter: 1,
  redemption_count: 0,
  hours_valid: 48,
  timing_methods: ['home?'],
  timing_parameters: { minutes_before: 60 },
  api_methods: %w[home? scored_in?],
  api_parameters: { period: 3 },
  team: Team.find_by(short_name: 'cbj', region: 'oh', league: League.find_by(short_name: 'nhl'))
)
Promotion.create!(
  company: "Jet's Pizza",
  name: "Jet's Pizza Score Twice Half Price",
  promo_type: 'order_discounts',
  promo_code: 'CBJ50',
  source_url: 'https://www.nhl.com/bluejackets/fans/gameday-central',
  redemption_limiter: 0,
  redemption_count: 0,
  hours_valid: 24,
  timing_methods: [],
  timing_parameters: {},
  api_methods: %w[home? goal_count_equal_or_above?],
  api_parameters: { goals_count: 2 },
  team: Team.find_by(short_name: 'cbj', region: 'oh', league: League.find_by(short_name: 'nhl'))
)
Promotion.create!(
  company: 'Roosters',
  name: 'Free Roosters Chili',
  promo_type: 'free_gifts',
  promo_code: nil,
  source_url: 'https://www.nhl.com/bluejackets/fans/gameday-central',
  redemption_limiter: 0,
  redemption_count: 0,
  hours_valid: 24,
  timing_methods: [],
  timing_parameters: {},
  api_methods: %w[home? goal_count_equal_or_above?],
  api_parameters: { goals_count: 3 },
  team: Team.find_by(short_name: 'cbj', region: 'oh', league: League.find_by(short_name: 'nhl'))
)
Promotion.create!(
  company: 'Tim Hortons',
  name: 'Tim Hortons - Free Coffee',
  promo_type: 'free_gifts',
  promo_code: nil,
  source_url: 'https://www.nhl.com/bluejackets/fans/gameday-central',
  redemption_limiter: 0,
  redemption_count: 0,
  hours_valid: 24,
  timing_methods: [],
  timing_parameters: {},
  api_methods: %w[home? won?],
  api_parameters: { goals_count: 3 },
  team: Team.find_by(short_name: 'cbj', region: 'oh', league: League.find_by(short_name: 'nhl'))
)
### Ohio Hockey Team End
