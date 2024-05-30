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

League.create!(full_name: 'national hockey league', short_name: 'nhl', start_month: 9, end_month: '7+') # October 10, 2023 – June 2024
# League.create!(full_name: 'national football league', short_name: 'nfl', start_month: 8, end_month: '2+') # September 5, 2024 – January 5, 2025
# League.create!(full_name: 'major league baseball', short_name: 'mlb', start_month: 4, end_month: '10') # March 20 – September 29, 2024
# League.create!(full_name: 'national basketball association', short_name: 'nba', start_month: 9, end_month: '5+') # October to April
League.create!(full_name: 'major league soccer', short_name: 'mls', start_month: 2, end_month: '11') # late March/early April to late September/early October
# League.create!(full_name: 'canadian football league', short_name: 'cfl', start_month: 5, end_month: '11') # June 6 – October 26, 2024
